//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "FlickrKit.h"
#import "HPPRFlickrPhotoProvider.h"
#import "HPPR.h"
#import "HPPRFlickrLoginProvider.h"
#import "HPPRFlickrMedia.h"
#import "HPPRFlickrAlbum.h"
#import "HPPRCacheService.h"
#import "NSBundle+HPPRLocalizable.h"

#define FLICKR_ERROR_DOMAIN @"com.devedup.flickrapi.ErrorDomain"
#define PHOTOSET_NOT_FOUND_ERROR_CODE 1

@interface HPPRFlickrPhotoProvider()

@property (nonatomic, strong) NSString *numberOfPages;
@property (nonatomic, strong) NSString *nextPage;
@property (nonatomic, strong) FKFlickrNetworkOperation *imageApiOperation;
@property (nonatomic, strong) FKFlickrNetworkOperation *albumApiOperation;
@property (nonatomic, strong) NSString *lastUserID;

@end

@implementation HPPRFlickrPhotoProvider

#pragma mark - Initialization

+ (HPPRFlickrPhotoProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRFlickrPhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRFlickrPhotoProvider alloc] init];
        sharedInstance.loginProvider = [HPPRFlickrLoginProvider sharedInstance];
        [[FlickrKit sharedFlickrKit] initializeWithAPIKey:[HPPR sharedInstance].flickrAppKey sharedSecret:[HPPR sharedInstance].flickrAppSecret];
    });
    return sharedInstance;
}

- (void)applicationDidStart
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[HPPRFlickrLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
            if (loggedIn) {
                [self albumsWithRefresh:YES andCompletion:^(NSArray *albums, NSError *error) {
                    if (!error) {
                        for (HPPRFlickrAlbum *album in albums) {
                            [self coverPhotoForAlbum:album withRefresh:YES andCompletion:nil];
                        }
                        [self landingPagePhotoWithRefresh:YES andCompletion:nil];
                    }
                }];
            }
        }];
    });
}

#pragma mark - User Interface

- (NSString *)name
{
    return @"Flickr";
}

- (BOOL)showSearchButton
{
    return NO;
}

- (NSString *)titleText
{
    return [NSString stringWithFormat:HPPRLocalizedString(@"%@ Photos", @"Photos of the specified social network"), self.name];
}

- (NSString *)headerText
{
    NSMutableString *text = [NSMutableString stringWithString:@""];
    NSUInteger count = self.album.photoCount;
    
    if (nil != self.album.name) {
        text = [NSMutableString stringWithFormat:@"%@", self.album.name];
    }
    
    if (1 == count) {
        [text appendString:HPPRLocalizedString(@" (1 photo)", nil)];
    } else if (count > 1) {
        [text appendFormat:HPPRLocalizedString(@" (%lu photos)", @"Number of photos"), (unsigned long)count];
    }

    return [NSString stringWithString:text];
}

#pragma mark - Photo requests

- (void)cancelAllOperations
{
    [super cancelAllOperations];
    [self.imageApiOperation cancel];
    [self.albumApiOperation cancel];
}

- (BOOL)isImageRequestsCancelled
{
    BOOL cancelled = super.isImageRequestsCancelled;
    
    if (self.imageApiOperation) {
        cancelled = self.imageApiOperation.isCancelled;
    }
    
    return cancelled;
}

- (BOOL)hasMoreImages
{
    NSInteger numberOfPages = [self.numberOfPages integerValue];
    NSInteger nextPage = [self.nextPage integerValue];
    
    return (nextPage <= numberOfPages);
}

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    if (reload) {
        self.numberOfPages = nil;
        self.nextPage = nil;
    }
    
    [self photosForAlbum:self.album.objectID withRefresh:reload andPaging:self.nextPage andCompletion:^(NSDictionary *photos, NSError *error) {
        NSArray *records = [photos objectForKey:@"data"];
        if (reload) {
            [self replaceImagesWithRecords:records];
        } else {
            [self updateImagesWithRecords:records];
        }
        
        if (completion) {
            completion(records);
        }
    }];
}

#pragma mark - Albums

- (void)refreshAlbumWithCompletion:(void (^)(NSError *error))completion
{
    if (nil != self.album.objectID) {
        [self call:@"flickr.photosets.getInfo" args:@{@"photoset_id": self.album.objectID} refresh:YES apiOperation:self.albumApiOperation completion:^(NSDictionary *response, NSError *error) {
            if (error) {
                NSLog(@"FLICKR ALBUMS ERROR\n%@", error);
                
                if ([error.domain isEqualToString:FLICKR_ERROR_DOMAIN] && (error.code == PHOTOSET_NOT_FOUND_ERROR_CODE)) {
                    if (completion) {
                        completion([HPPRAlbum albumDeletedError]);
                    }
                } else {
                    if (completion) {
                        completion(error);
                    }
                }
            } else {
                
                NSDictionary *photoset = [response objectForKey:@"photoset"];
                [self.album setAttributes:photoset];
                
                if (completion) {
                    completion(nil);
                }
            }
        }];
    } else {
        if (completion) {
            completion(nil);
        }
    }
}

- (void)albumsWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *albums, NSError *error))completion
{
    BOOL shouldRefresh = refresh;
    HPPRFlickrLoginProvider *loginProvider = (HPPRFlickrLoginProvider *)self.loginProvider;
    NSString *currentUserID = [loginProvider.user objectForKey:@"userID"];
    if (![currentUserID isEqualToString:self.lastUserID]) {
        shouldRefresh = YES;
        self.lastUserID = currentUserID;
    }
    [self call:@"flickr.photosets.getList" args:@{@"per_page":FLICKR_MAX_PER_PAGE, @"primary_photo_extras": @"url_m,url_o"} refresh:shouldRefresh apiOperation:self.albumApiOperation completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"FLICKR ALBUMS ERROR\n%@", error);
            if (completion) {
                completion(nil, error);
            }
        } else {
            NSMutableArray *albums = [NSMutableArray array];
            
            HPPRFlickrAlbum *allPhotos = [[HPPRFlickrAlbum alloc] init];
            allPhotos.name = HPPRLocalizedString(@"All Photos", @"Indicates that all photos will be displayed");
            [albums addObject:allPhotos];
            
            for (NSDictionary *photoset in [[response objectForKey:@"photosets"] objectForKey:@"photoset"]) {
                [albums addObject:[[HPPRFlickrAlbum alloc] initWithAttributes:photoset]];
            }
            
            allPhotos.coverPhotoThumbnailURL = ((HPPRFlickrAlbum *)(albums[albums.count - 1])).coverPhotoThumbnailURL;
            allPhotos.coverPhotoFullSizeURL = ((HPPRFlickrAlbum *)(albums[albums.count - 1])).coverPhotoFullSizeURL;
            allPhotos.provider = ((HPPRFlickrAlbum *)(albums[albums.count - 1])).provider;

            if (completion) {
                completion([NSArray arrayWithArray:albums], nil);
            }
        }
    }];
}

- (void)retrieveExtraMediaInfo:(HPPRMedia *)media withRefresh:(BOOL)refresh andCompletion:(void (^)(NSError *error))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self infoForPhoto:media.objectID withRefresh:refresh andCompletion:^(NSDictionary *photoInfo, NSError *error) {
            if (!error) {
                [self updateMedia:(HPPRFlickrMedia *)media withPhotoInfo:photoInfo];
                
                [self favoritesForPhoto:media.objectID withRefresh:refresh andCompletion:^(NSArray *favorites, NSError *error) {
                    if (!error) {
                        media.likes = [favorites count];
                    }
                    
                    if (completion) {
                        completion(error);
                    }
                }];
            } else {
                if (completion) {
                    completion(error);
                }
            }
        }];
    });
}

- (void)photosForAlbum:(NSString *)albumID withRefresh:(BOOL)refresh andPaging:(NSString *)afterID andCompletion:(void (^)(NSDictionary *photos, NSError *error))completion
{
    NSString *call = nil;
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args addEntriesFromDictionary:@{@"page": ((afterID == nil) ? @"1" : afterID), @"per_page":FLICKR_MAX_PER_PAGE, @"extras": @"url_m,url_o,date_taken,geo"}];
    if (nil != albumID) {
        call = @"flickr.photosets.getPhotos";
        [args setObject:albumID forKey:@"photoset_id"];
    } else {
        call = @"flickr.people.getPhotos";
        [args setObject:@"me" forKey:@"user_id"];
    }
    
    [self call:call args:args refresh:refresh apiOperation:self.imageApiOperation completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"FLICKR ALBUM ERROR\n%@", error);
            if (completion) {
                completion(nil, error);
            }
        } else {
            NSDictionary *photoSet = [response objectForKey:@"photoset"];
            if (photoSet == nil) {
                photoSet = [response objectForKey:@"photos"];
            }
            
            self.numberOfPages = [photoSet objectForKey:@"pages"];
            NSInteger currentPage = [[photoSet objectForKey:@"page"] integerValue];
            self.nextPage = [NSString stringWithFormat:@"%ld", (long)(currentPage + 1)];
            
            NSMutableArray *mutableRecords = [NSMutableArray array];
            for (NSDictionary *photo in [photoSet objectForKey:@"photo"]) {
                __block HPPRFlickrMedia *media = [[HPPRFlickrMedia alloc] initWithAttributes:photo];
                [mutableRecords addObject:media];
            }
            NSDictionary *result = @{ @"data":mutableRecords.copy };
            if (completion) {
                completion(result, nil);
            }
        }
    }];
}

- (void)landingPagePhotoWithRefresh:(BOOL)refresh andCompletion:(void (^)(UIImage *photo, NSError *error))completion
{
    [self albumsWithRefresh:refresh andCompletion:^(NSArray *albums, NSError *error) {
        if (error) {
            NSLog(@"LANDING PAGE PHOTO ERROR\n%@", error);
            if (completion) {
                completion(nil, error);
            }
        } else {
            if (0 == [albums count]) {
                if (completion) {
                    completion(nil, [[NSError alloc] init]);
                }
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    HPPRFlickrAlbum * firstAlbum = (HPPRFlickrAlbum *)albums[0];
                    UIImage * photo = [[HPPRCacheService sharedInstance] imageForUrl:firstAlbum.coverPhotoFullSizeURL];
                    if (completion) {
                        completion(photo, nil);
                    }
                });
            }
        }
    }];
}

- (void)coverPhotoForAlbum:(HPPRAlbum *)album withRefresh:(BOOL)refresh andCompletion:(void (^)(HPPRAlbum *album, UIImage *coverPhoto, NSError *error))completion
{
    HPPRFlickrAlbum *flickrAlbum = (HPPRFlickrAlbum *)album;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        album.coverPhoto = [[HPPRCacheService sharedInstance] imageForUrl:flickrAlbum.coverPhotoThumbnailURL];
        if (completion) {
            completion(album, album.coverPhoto, nil);
        }
    });
}

#pragma mark - Private methods

- (void)call:(NSString *)apiMethod args:(NSDictionary *)requestArgs refresh:(BOOL)refresh apiOperation:(FKFlickrNetworkOperation *)apiOperation completion:(FKAPIRequestCompletion)completion
{
    FKDUMaxAge cacheAge = refresh ? FKDUMaxAgeNeverCache : FKDUMaxAgeOneHour;
    apiOperation = [[FlickrKit sharedFlickrKit] call:apiMethod args:requestArgs maxCacheAge:cacheAge completion:^(NSDictionary *response, NSError *error) {
        if (completion) {
            completion(response, error);
        }
        if (FKErrorNotAuthorized == error.code || FLICKR_INVALID_TOKEN_ERROR_CODE == error.code) {
            [self lostAccess];
        }
        if (FKErrorNoInternet == error.code) {
            [self lostConnection];
        }
    }];
}


- (void)infoForPhoto:(NSString *)photoID withRefresh:(BOOL)refresh andCompletion:(void (^)(NSDictionary *photoInfo, NSError *error))completion
{
    [self call:@"flickr.photos.getInfo" args:@{@"photo_id":photoID} refresh:refresh apiOperation:self.imageApiOperation completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"FLICKR PHOTO INFO ERROR\n%@", error);
            if (completion) {
                completion(nil, error);
            }
        } else {
            if (completion) {
                completion([response objectForKey:@"photo"], nil);
            }
        }
    }];
}

- (void)favoritesForPhoto:(NSString *)photoID withRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *favorites, NSError *error))completion
{
    [self call:@"flickr.photos.getFavorites" args:@{ @"photo_id":photoID, @"per_page":FLICKR_MAX_FAVORITES_PER_PAGE } refresh:refresh apiOperation:self.imageApiOperation completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"FLICKR PHOTO FAVORITES ERROR\n%@", error);
            if (completion) {
                completion(nil, error);
            }
        } else {
            if (completion) {
                completion([response valueForKeyPath:@"photo.person"], nil);
            }
        }
    }];
}

- (void)updateMedia:(HPPRFlickrMedia *)media withPhotoInfo:(NSDictionary *)photoInfo
{
    media.comments = [[photoInfo valueForKeyPath:@"comments._content"] integerValue];
    NSString *latitude = [photoInfo valueForKeyPath:@"location.latitude"];
    NSString *longitude = [photoInfo valueForKeyPath:@"location.longitude"];
    if (latitude && longitude) {
        media.location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    }
}

@end
