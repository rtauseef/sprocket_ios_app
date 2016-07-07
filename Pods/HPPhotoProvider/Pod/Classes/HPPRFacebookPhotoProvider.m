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

#import "HPPRFacebookPhotoProvider.h"
#import "HPPRFacebookLoginProvider.h"
#import "HPPRFacebookMedia.h"
#import "HPPRCacheService.h"
#import "HPPRFacebookAlbum.h"
#import "NSBundle+HPPRLocalizable.h"

#define PAGING_ALL @"All"
#define FACEBOOK_ERROR_DOMAIN @"com.facebook.sdk"
#define ALBUM_NOT_FOUND_ERROR_CODE 5


@interface HPPRFacebookPhotoProvider() <HPPRLoginProviderDelegate>

@property (strong, nonatomic) NSString *maxPhotoID;

@end

@implementation HPPRFacebookPhotoProvider

#pragma mark - Initialization

+ (HPPRFacebookPhotoProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRFacebookPhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRFacebookPhotoProvider alloc] init];
        sharedInstance.loginProvider = [HPPRFacebookLoginProvider sharedInstance];
        sharedInstance.loginProvider.delegate = sharedInstance;
    });
    return sharedInstance;
}

- (void)applicationDidStart
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [[HPPRFacebookLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
            if (loggedIn) {
                [self userInfoWithRefresh:YES andCompletion:^(NSDictionary<FBGraphUser> *userInfo, NSError *error) {
                    if (!error) {
                        [self albumsWithRefresh:YES andCompletion:^(NSArray *albums, NSError *error) {
                            if (!error) {
                                for (HPPRFacebookAlbum *album in albums) {
                                    [self coverPhotoForAlbum:album withRefresh:YES andCompletion:nil];
                                }
                            }
                        }];
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
    return @"Facebook";
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

- (void)retrieveExtraMediaInfo:(HPPRMedia *)media withRefresh:(BOOL)refresh andCompletion:(void (^)(NSError *error))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self likesForPhoto:media.objectID withRefresh:refresh andCompletion:^(NSArray *likes, NSError *error) {
            if (error) {
                NSLog(@"LIKES ERROR\n%@", error);
                
                if (completion) {
                    completion(error);
                }
            } else {
                media.likes = likes.count;
                
                [self commentsForPhoto:media.objectID withRefresh:refresh andCompletion:^(NSArray *comments, NSError *error) {
                    if (error) {
                        NSLog(@"COMMENTS ERROR\n%@", error);
                    } else {
                        media.comments = comments.count;
                    }
                    
                    if (completion) {
                        completion(error);
                    }
                }];
            }
        }];
    });
}

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    if (reload) {
        self.maxPhotoID = nil;
    }
    
    [self photosForAlbum:self.album.objectID withRefresh:reload andPaging:self.maxPhotoID andCompletion:^(NSDictionary *photoInfo, NSError *error) {
        
        NSArray *records = nil;
        
        if (!error) {
            NSArray * photos = [photoInfo objectForKey:@"data"];
            NSString *maxPhotoID = [[[photoInfo objectForKey:@"paging"] objectForKey:@"cursors"] objectForKey:@"after"];
            NSMutableArray *mutableRecords = [NSMutableArray array];
            for (NSDictionary * photo in photos) {
                __block HPPRFacebookMedia * media = [[HPPRFacebookMedia alloc] initWithAttributes:photo];
                [mutableRecords addObject:media];
            }
            
            records = mutableRecords.copy;
            
            if (self.maxPhotoID) {
                [self updateImagesWithRecords:records];
            } else {
                [self replaceImagesWithRecords:records];
            }
            self.maxPhotoID = maxPhotoID;
        } else {
            NSLog(@"ALBUM PHOTOS ERROR\n%@", error);
            [self lostAccess];
        }
        
        if (completion) {
            completion(records);
        }
    }];
    
}

- (BOOL)hasMoreImages
{
    return (nil != self.maxPhotoID);
}

#pragma mark - Graph requests

- (void)albumsWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *albums, NSError *error))completion
{
    [self cachedGraphRequest:@"me/albums" withRefresh:refresh andPaging:PAGING_ALL andCompletion:^(id result, NSError *error) {
        if (error) {
            NSLog(@"FACEBOOK ERROR\n%@", error);
            [self lostAccess];
            if (completion) {
                completion(nil, error);
            }
        } else {
            NSMutableArray *facebookAlbums = [NSMutableArray array];
            
            HPPRFacebookAlbum *allPhotos = [[HPPRFacebookAlbum alloc] init];
            allPhotos.name = HPPRLocalizedString(@"All Photos", @"Indicates all photos will be shown");
            allPhotos.objectID = nil;
            
            [facebookAlbums addObject:allPhotos];
            for (NSDictionary *album in result) {
                [facebookAlbums addObject:[[HPPRFacebookAlbum alloc] initWithAttributes:album]];
            }
            
            allPhotos.coverPhotoID = ((HPPRFacebookAlbum *)(facebookAlbums[facebookAlbums.count - 1])).coverPhotoID;
            allPhotos.provider = ((HPPRFacebookAlbum *)(facebookAlbums[facebookAlbums.count - 1])).provider;

            if (completion) {
                completion([NSArray arrayWithArray:facebookAlbums], nil);
            }
        }
        
    }];
}

- (void)refreshAlbumWithCompletion:(void (^)(NSError *error))completion
{
    NSString *request = @"me/photos/uploaded";
    if (nil != self.album.objectID) {
        request = [NSString stringWithFormat:@"%@", self.album.objectID];
    }
    
    [self cachedGraphRequest:request withRefresh:YES andPaging:nil andCompletion:^(id result, NSError *error) {
        if (error) {
            if ([error.domain isEqualToString:FACEBOOK_ERROR_DOMAIN] && (error.code == ALBUM_NOT_FOUND_ERROR_CODE)) {
                if (completion) {
                    completion([HPPRAlbum albumDeletedError]);
                }
            } else {
                NSLog(@"FACEBOOK ERROR\n%@", error);
                [self lostAccess];
                if (completion) {
                    completion(error);
                }
            }
        } else {
            [self.album setAttributes:result];
            
            if (completion) {
                completion(nil);
            }
        }
    }];
}

- (void)photosForAlbum:(NSString *)albumID withRefresh:(BOOL)refresh andPaging:(NSString *)afterID andCompletion:(void (^)(NSDictionary *photos, NSError *error))completion
{
    NSString *query = [NSString stringWithFormat:@"%@/photos", albumID];
    if (nil == albumID) {
        query = @"me/photos/uploaded";
    }
    
    [self cachedGraphRequest:query withRefresh:refresh andPaging:afterID andCompletion:completion];
}

- (void)photoByID:(NSString *)photoID withRefresh:(BOOL)refresh andCompletion:(void (^)(NSDictionary *photoInfo, NSError *error))completion
{
    [self cachedGraphRequest:photoID withRefresh:refresh andPaging:nil andCompletion:completion];
}

- (void)userInfoWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSDictionary<FBGraphUser> *userInfo, NSError *error))completion
{
    [self cachedGraphRequest:@"me" withRefresh:refresh andPaging:nil andCompletion:completion];
}

- (void)likesForPhoto:(NSString *)photoID withRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *likes, NSError * error))completion
{
    [self cachedGraphRequest:[NSString stringWithFormat:@"%@/likes", photoID] withRefresh:refresh andPaging:PAGING_ALL andCompletion:completion];
}

- (void)commentsForPhoto:(NSString *)photoID withRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *comments, NSError * error))completion
{
    [self cachedGraphRequest:[NSString stringWithFormat:@"%@/comments", photoID] withRefresh:refresh andPaging:PAGING_ALL andCompletion:completion];
}

- (void)landingPagePhotoWithRefresh:(BOOL)refresh andCompletion:(void (^)(UIImage *photo, NSError *error))completion
{
    [self albumsWithRefresh:refresh andCompletion:^(NSArray *albums, NSError *error) {
        if (!error && [albums count] > 0) {
            HPPRAlbum * firstAlbum = (HPPRAlbum *)albums[0];
            [self photosForAlbum:firstAlbum.objectID withRefresh:refresh andPaging:nil andCompletion:^(NSDictionary *photos, NSError *error) {
                if (error) {
                    if (completion) {
                        completion(nil, error);
                    }
                } else if ([[photos objectForKey:@"data"] count] > 0) {
                    NSString *url = [[HPPRFacebookPhotoProvider sharedInstance] urlForLargestPhoto:[photos objectForKey:@"data"][0]];
                    UIImage * photo = [[HPPRCacheService sharedInstance] imageForUrl:url];
                    if (completion) {
                        completion(photo, nil);
                    }
                } else {
                    [self useFallbackLandingPagePhotoWithRefresh:refresh andCompletion:completion];
                }
            }];
        } else {
            [self useFallbackLandingPagePhotoWithRefresh:refresh andCompletion:completion];
        }
    }];
}

- (void)useFallbackLandingPagePhotoWithRefresh:(BOOL)refresh andCompletion:(void (^)(UIImage *photo, NSError *error))completion
{
    [self userInfoWithRefresh:refresh andCompletion:^(NSDictionary<FBGraphUser> *userInfo, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
        } else {
            NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=1024&height=1024", [userInfo objectID]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *photo = [[HPPRCacheService sharedInstance]imageForUrl:url];
                if (completion) {
                    completion(photo, nil);
                }
            });
        }
    }];
}

- (void)coverPhotoForAlbum:(HPPRAlbum *)album withRefresh:(BOOL)refresh andCompletion:(void (^)(HPPRAlbum *album, UIImage *coverPhoto, NSError *error))completion
{
    HPPRFacebookAlbum *facebookAlbum = (HPPRFacebookAlbum *)album;
    
    if (facebookAlbum.coverPhotoID == nil) {
        if (completion) {
            completion(album, [UIImage imageNamed:@"HPPRFacebookNoPhotoAlbum"], nil);
        }
        return;
    }
    
    [[HPPRFacebookPhotoProvider sharedInstance] photoByID:facebookAlbum.coverPhotoID withRefresh:refresh andCompletion:^(NSDictionary *photoInfo, NSError *error) {
        if (error) {
            NSLog(@"PHOTO ERROR\n%@", error);
            [self lostAccess];
            if (completion) {
                completion(facebookAlbum, nil, error);
            }
        } else {
            NSString *url = [[HPPRFacebookPhotoProvider sharedInstance] urlForSmallestPhoto:photoInfo];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                album.coverPhoto = [[HPPRCacheService sharedInstance] imageForUrl:url];
                if (completion) {
                    completion(album, album.coverPhoto, nil);
                }
            });
        }
    }];
}

#pragma mark - Photo helpers

- (NSString *)urlForPhoto:(NSDictionary *)photoInfo withHeight:(NSUInteger)height
{
    for (NSDictionary *imageInfo in [photoInfo objectForKey:@"images"]) {
        if (height == [[imageInfo objectForKey:@"height"] integerValue]) {
            return [imageInfo objectForKey:@"source"];
        }
    }
    
    return nil;
}

- (NSString *)urlForSmallestPhoto:(NSDictionary *)photoInfo
{
    NSString * smallestURL = nil;
    NSUInteger smallestWidth = 1E6;
    
    for (NSDictionary *imageInfo in [photoInfo objectForKey:@"images"]) {
        NSUInteger width = [[imageInfo objectForKey:@"width"] integerValue];
        if (nil == smallestURL) {
            smallestURL = [imageInfo objectForKey:@"source"];
            smallestWidth = width;
        } else {
            if (width < smallestWidth) {
                smallestURL = [imageInfo objectForKey:@"source"];
                smallestWidth = width;
            }
        }
    }
    
    return smallestURL;
}

- (NSString *)urlForLargestPhoto:(NSDictionary *)photoInfo
{
    NSString * largestURL = nil;
    NSUInteger largestWidth = 0;
    
    for (NSDictionary *imageInfo in [photoInfo objectForKey:@"images"]) {
        NSUInteger width = [[imageInfo objectForKey:@"width"] integerValue];
        if (nil == largestURL) {
            largestURL = [imageInfo objectForKey:@"source"];
            largestWidth = width;
        } else {
            if (width > largestWidth) {
                largestURL = [imageInfo objectForKey:@"source"];
                largestWidth = width;
            }
        }
    }
    
    return largestURL;
}

#pragma mark - Private methods

- (void)cachedGraphRequest:(NSString *)query withRefresh:(BOOL)refresh andPaging:(NSString *)afterID andCompletion:(void (^)(id result, NSError *error))completion
{
    NSMutableString *fullQuery = [NSMutableString stringWithString:query];
    if (afterID) {
        [fullQuery appendFormat:@"?after=%@", afterID];
    }
    id cachedResult = [self retrieveFromCacheWithKey:fullQuery];
    
    if (cachedResult && !refresh) {
        if (completion) {
            completion(cachedResult, nil);
        }
    } else {
        __weak HPPRFacebookPhotoProvider * weakSelf = self;
        if ([afterID isEqual:PAGING_ALL]) {
            NSMutableArray * list = [[NSMutableArray alloc] init];
            [weakSelf addToList:list query:query withPaging:nil withRefresh:refresh andCompletion:^(NSArray *list, NSError *error) {
                if (!error) {
                    [weakSelf saveToCache:list withKey:fullQuery];
                }
                [weakSelf processResult:list withError:error andCompletion:completion];
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [FBRequestConnection startWithGraphPath:fullQuery completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        [weakSelf saveToCache:result withKey:fullQuery];
                    }
                    [weakSelf processResult:result withError:error andCompletion:completion];
                }];
            });
        }
    }
    
}

- (void)addToList:(NSMutableArray *)itemList query:(NSString *)baseQuery withPaging:(NSString *)afterID withRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *list, NSError *error))completion
{
    __weak HPPRFacebookPhotoProvider * weakSelf = self;
    [self cachedGraphRequest:baseQuery withRefresh:refresh andPaging:afterID andCompletion:^(id result, NSError *error) {
        if(error) {
            if (completion) {
                completion(nil, error);
            }
        } else {
            NSArray *newItems = [result objectForKey:@"data"];
            [itemList addObjectsFromArray:newItems];
            NSString *maxID = [[[result objectForKey:@"paging"] objectForKey:@"cursors"] objectForKey:@"after"];
            if(maxID) {
                [weakSelf addToList:itemList query:baseQuery withPaging:maxID withRefresh:refresh andCompletion:completion];
            } else {
                if(completion) {
                    completion([NSArray arrayWithArray:itemList], nil);
                }
            }
        }
    }];
}

- (void)processResult:(id)result withError:(NSError *)error andCompletion:(void (^)(id result, NSError *error))completion
{
    if (error) {
        if (completion) {
            completion(nil, error);
        }
    } else {
        if (completion) {
            completion(result, nil);
        }
    }
}

#pragma mark - HPPRLoginProviderDelegate

- (void)didLogoutWithProvider:(HPPRLoginProvider *)loginProvider
{
    [self clearCache];
}

@end

