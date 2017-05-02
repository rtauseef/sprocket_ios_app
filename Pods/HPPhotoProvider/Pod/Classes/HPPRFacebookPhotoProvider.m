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
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "HPPR.h"

#define PAGING_ALL @"All"
#define FACEBOOK_ERROR_DOMAIN @"com.facebook.sdk"
#define ALBUM_NOT_FOUND_ERROR_CODE 5


@interface HPPRFacebookPhotoProvider() <HPPRLoginProviderDelegate>

@property (strong, nonatomic) NSString *maxPhotoID;
@property (strong, nonatomic) FBSDKGraphRequestConnection *lastPhotoRequestConnection;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.displayVideos = [[HPPR sharedInstance] showVideos];
    }
    return self;
}

- (void)applicationDidStart
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [[HPPRFacebookLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
            if (loggedIn) {
                [self userInfoWithRefresh:YES andCompletion:^(NSDictionary *userInfo, NSError *error) {
                    if (!error) {
                        [self albumsWithRefresh:YES andCompletion:^(NSArray *albums, NSError *error) {
                            if (!error) {
                                for (HPPRFacebookAlbum *album in albums) {
                                    [self coverPhotoForAlbum:album withRefresh:YES andCompletion:nil];
                                }
                            }
                        }];
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
        
        [self likesCountForPhoto:media.objectID withRefresh:refresh andCompletion:^(NSNumber *totalLikes, NSError *error) {
            if (error) {
                media.likes = 0;
                media.comments = 0;
                if (completion) {
                    completion(error);
                }
            } else {
                media.likes = [totalLikes integerValue];
                [self commentsCountForPhoto:media.objectID withRefresh:refresh andCompletion:^(NSNumber *totalComments, NSError *error) {
                    if (error) {
                        media.comments = 0;
                        if (completion) {
                            completion(error);
                        }
                    } else {
                        media.comments = [totalComments integerValue];
                        if (completion) {
                            completion(nil);
                        }
                    }

                }];
            }
        }];
        
    });
}

- (void)requestVideosWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload {
    [self videosForAlbum:self.album.objectID withRefresh:reload andPaging:self.maxPhotoID andCompletion:^(NSDictionary *videoInfo, NSError *error) {
        
        NSArray *records = nil;
        
        if (!error) {
            NSArray * videos = [videoInfo objectForKey:@"data"];
            NSString *maxVideoID = [[[videoInfo objectForKey:@"paging"] objectForKey:@"cursors"] objectForKey:@"after"];
            NSMutableArray *mutableRecords = [NSMutableArray array];
            
            for (NSDictionary * video in videos) {
                __block HPPRFacebookMedia * media = [[HPPRFacebookMedia alloc] initWithVideoAttributes:video];
                [mutableRecords addObject:media];
            }
            
            records = mutableRecords.copy;
            
            if (self.maxPhotoID) {
                [self updateImagesWithRecords:records];
            } else {
                [self replaceImagesWithRecords:records];
            }
            
            self.maxPhotoID = maxVideoID;
        } else {
            NSLog(@"ALBUM VIDEOS ERROR\n%@", error);
            [self lostAccess];
        }
        
        if (completion) {
            completion(records);
        }
    }];
}

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    if (reload) {
        self.maxPhotoID = nil;
    }
    
    if (self.album.videoOnly) {
        [self requestVideosWithCompletion:completion andReloadAll:reload];
    } else {
    
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
}

- (BOOL)hasMoreImages
{
    return (nil != self.maxPhotoID);
}

#pragma mark - Graph requests

- (void)albumsWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *albums, NSError *error))completion
{
    [self cachedGraphRequest:@"me/albums" parameters:@{ @"fields":@"count,cover_photo,name" } refresh:refresh paging:PAGING_ALL completion:^(id result, NSError *error) {
        if (error) {
            NSLog(@"FACEBOOK ERROR\n%@", error);
            [self lostAccess];
            if (completion) {
                completion(nil, error);
            }
        } else {
            NSMutableArray *facebookAlbums = [NSMutableArray array];
            
            HPPRFacebookAlbum *allPhotos = [[HPPRFacebookAlbum alloc] init];
            allPhotos.name = HPPRLocalizedString(@"All Photos", @"Indicates that all photos will be displayed");
            allPhotos.objectID = nil;
            
            [facebookAlbums addObject:allPhotos];
            for (NSDictionary *album in result) {
                [facebookAlbums addObject:[[HPPRFacebookAlbum alloc] initWithAttributes:album]];
            }
            
            allPhotos.coverPhotoID = ((HPPRFacebookAlbum *)(facebookAlbums[facebookAlbums.count - 1])).coverPhotoID;
            allPhotos.provider = ((HPPRFacebookAlbum *)(facebookAlbums[facebookAlbums.count - 1])).provider;

            if (self.displayVideos) {
                [self cachedGraphRequest:@"me/videos/uploaded" parameters:@{ @"fields":@"picture" } refresh:refresh paging:PAGING_ALL completion:^(id result, NSError *error) {
                    if (error) {
                        NSLog(@"FACEBOOK ERROR\n%@", error);
                        [self lostAccess];
                        if (completion) {
                            completion(nil, error);
                        }
                    } else {
                        HPPRFacebookAlbum *allVideos = [[HPPRFacebookAlbum alloc] init];
                        allVideos.name = HPPRLocalizedString(@"Videos", @"Indicates that all videos will be displayed");
                        allVideos.objectID = nil;
                        allVideos.videoOnly = YES;
                        allVideos.coverPhotoID = nil;
                        allVideos.provider = ((HPPRFacebookAlbum *)(facebookAlbums[facebookAlbums.count - 1])).provider;
                        
                        for (NSDictionary *entry in result) { // there should be just one
                            allVideos.coverPhotoURL = [entry objectForKey:@"picture"];
                        }
                        
                        [facebookAlbums addObject:allVideos];
                        
                        if (completion) {
                            completion([NSArray arrayWithArray:facebookAlbums], nil);
                        }
                    }
                }];
                
            } else {
                
                if (completion) {
                    completion([NSArray arrayWithArray:facebookAlbums], nil);
                }
            }
        }
        
    }];
}

- (void)refreshAlbumWithCompletion:(void (^)(NSError *error))completion
{
    NSString *request = [NSMutableString string];
    NSString *fields = [NSMutableString string];
    
    if (nil != self.album.objectID) {
        request = [NSString stringWithFormat:@"%@", self.album.objectID];
        fields = @"count,cover_photo,name";
    } else {
        if (self.album.videoOnly) {
            request = @"me/videos/uploaded";
            fields = @"created_time,thumbnails,place,picture";
            
        } else {
            request = @"me/photos/uploaded";
            fields = @"count,cover_photo,name";
        }
    }
    
    [self cachedGraphRequest:request parameters:@{ @"fields":fields } refresh:YES paging:nil completion:^(id result, NSError *error) {
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
            if (self.album.objectID != nil) {
                [self.album setAttributes:result];
            }
            
            if (completion) {
                completion(nil);
            }
        }
    }];
}

- (void)photosForAlbum:(NSString *)albumID withRefresh:(BOOL)refresh andPaging:(NSString *)afterID andCompletion:(void (^)(NSDictionary *photos, NSError *error))completion
{
    NSString *query = [NSString stringWithFormat:@"%@/photos", albumID];
    NSDictionary *fields = @{@"fields":@"name,created_time,images,place,link"};
    if (nil == albumID) {
        query = @"me/photos/uploaded";
    }
    
    [self cachedGraphRequest:query parameters:fields refresh:refresh paging:afterID completion:completion];
}

- (void)photoByID:(NSString *)photoID withRefresh:(BOOL)refresh andCompletion:(void (^)(NSDictionary *photoInfo, NSError *error))completion
{
    NSDictionary *fields = @{@"fields":@"name,place,created_time,images"};
    [self cachedGraphRequest:photoID parameters:fields refresh:refresh paging:nil completion:completion];
}

- (void)videosForAlbum:(NSString *)albumID withRefresh:(BOOL)refresh andPaging:(NSString *)afterID andCompletion:(void (^)(NSDictionary *videoInfo, NSError *error))completion
{
    // me/videos/uploaded?fields=created_time,place,thumbnails
    NSString *query = @"me/videos/uploaded";
    
    [self cachedGraphRequest:query parameters:@{@"fields":@"created_time,thumbnails,place,picture"} refresh:refresh paging:afterID completion:completion];
}

- (void)userInfoWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSDictionary *userInfo, NSError *error))completion
{
    [self cachedGraphRequest:@"me" parameters:@{ @"fields":@"name,id" } refresh:refresh paging:nil completion:completion];
}

- (void)likesCountForPhoto:(NSString *)photoID withRefresh:(BOOL)refresh andCompletion:(void (^)(NSNumber *count, NSError * error))completion
{
    [self cachedGraphRequest:[NSString stringWithFormat:@"%@/likes", photoID] parameters:@{ @"limit":@"0", @"summary":@"total_count", @"fields":@"id" } refresh:refresh paging:nil completion:^(id result, NSError *error) {
        [self countFromResult:result error:error completion:completion];
    }];
}

- (void)commentsCountForPhoto:(NSString *)photoID withRefresh:(BOOL)refresh andCompletion:(void (^)(NSNumber *count, NSError * error))completion
{
    [self cachedGraphRequest:[NSString stringWithFormat:@"%@/comments", photoID] parameters:@{ @"limit":@"0", @"summary":@"total_count", @"fields":@"id" } refresh:refresh paging:nil completion:^(id result, NSError *error) {
        [self countFromResult:result error:error completion:completion];
    }];
}

- (void)coverPhotoForAlbum:(HPPRAlbum *)album withRefresh:(BOOL)refresh andCompletion:(void (^)(HPPRAlbum *album, UIImage *coverPhoto, NSError *error))completion
{
    HPPRFacebookAlbum *facebookAlbum = (HPPRFacebookAlbum *)album;
    
    if (facebookAlbum.coverPhotoID == nil && facebookAlbum.coverPhotoURL == nil) {
        if (completion) {
            completion(album, [UIImage imageNamed:@"HPPRFacebookNoPhotoAlbum"], nil);
        }
        return;
    }
    
    if (facebookAlbum.coverPhotoID != nil) {
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
    } else if (facebookAlbum.coverPhotoURL != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            album.coverPhoto = [[HPPRCacheService sharedInstance] imageForUrl:facebookAlbum.coverPhotoURL];
            if (completion) {
                completion(album, album.coverPhoto, nil);
            }
        });
    }
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

- (NSString *)urlForVideoPhoto:(NSDictionary *)photoInfo {
    NSDictionary *imageInfo = [photoInfo objectForKey:@"thumbnails"];
    
    if (imageInfo != nil) {
        NSArray *imageList = [imageInfo objectForKey:@"data"];
        if ([imageList count] > 0) {
            NSString *photoURL =[imageList[0] objectForKey:@"uri"];
            return photoURL;
        }
    }
    
    return nil;
}

- (NSString *)urlForVideoThumbnail:(NSDictionary *)photoInfo {
    return [photoInfo objectForKey:@"picture"];
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

- (void)countFromResult:(NSDictionary *)result error:(NSError *)error completion:(void (^)(NSNumber *count, NSError * error))completion
{
    if (!completion) {
        return;
    }
    
    if (error) {
        completion(nil, error);
    } else {
        NSNumber *count = nil;
        NSDictionary *summary = [result objectForKey:@"summary"];
        if (summary) {
            NSString *countValue = [summary objectForKey:@"total_count"];
            count = [NSNumber numberWithInteger:[countValue integerValue]];
        }
        if (count) {
            completion(count, nil);
        } else {
            completion(nil, [NSError errorWithDomain:@"HPPRFacebookPhotoProvider" code:-1 userInfo:@{@"error":@"Unable to retrieve count from result", @"result":result}]);
        }
    }
}

#pragma mark - Private methods

- (void)cachedGraphRequest:(NSString *)query parameters:(NSDictionary *)parameters refresh:(BOOL)refresh paging:(NSString *)afterID completion:(void (^)(id result, NSError *error))completion
{
    NSMutableDictionary *queryParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    if (afterID) {
        [queryParameters addEntriesFromDictionary:@{@"after":afterID}];
    }
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@?%@", query, [self parametersString:queryParameters]];
    
    id cachedResult = [self retrieveFromCacheWithKey:cacheKey];
    
    if (self.lastPhotoRequestConnection) {
        [self.lastPhotoRequestConnection cancel];
        self.lastPhotoRequestConnection = nil;
    }
    
    if (cachedResult && !refresh) {
        if (completion) {
            completion(cachedResult, nil);
        }
    } else {
        __weak HPPRFacebookPhotoProvider * weakSelf = self;
        if ([afterID isEqual:PAGING_ALL]) {
            NSMutableArray * list = [[NSMutableArray alloc] init];
            [weakSelf addToList:list query:query parameters:parameters paging:nil refresh:refresh completion:^(NSArray *list, NSError *error) {
                if (!error) {
                    [weakSelf saveToCache:list withKey:cacheKey];
                }
                [weakSelf processResult:list withError:error andCompletion:completion];
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                FBSDKGraphRequest *graphRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:query parameters:queryParameters];
                NSLog(@"\n\nVERSION: %@\nQUERY: %@\nPARAMS: %@\n\n", graphRequest.version, query, queryParameters);
                self.lastPhotoRequestConnection = [graphRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        [weakSelf saveToCache:result withKey:cacheKey];
                    } else {
                        NSLog(@"\n\nERROR:\n\n%@\n\n\n", error);
                    }
                    [weakSelf processResult:result withError:error andCompletion:completion];
                }];
                
           });
        }
    }
    
}

- (void)addToList:(NSMutableArray *)itemList query:(NSString *)baseQuery parameters:(NSDictionary *)parameters paging:(NSString *)afterID refresh:(BOOL)refresh completion:(void (^)(NSArray *list, NSError *error))completion
{
    __weak HPPRFacebookPhotoProvider * weakSelf = self;
    [self cachedGraphRequest:baseQuery parameters:parameters refresh:refresh paging:afterID completion:^(id result, NSError *error) {
        if(error) {
            if (completion) {
                completion(nil, error);
            }
        } else {
            NSArray *newItems = [result objectForKey:@"data"];
            [itemList addObjectsFromArray:newItems];
            NSString *maxID = [[[result objectForKey:@"paging"] objectForKey:@"cursors"] objectForKey:@"after"];
            if(maxID) {
                [weakSelf addToList:itemList query:baseQuery parameters:parameters paging:maxID refresh:refresh completion:completion];
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

- (NSString *)parametersString:(NSDictionary *)parameters
{
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in parameters.allKeys) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [parameters objectForKey:key]]];
    }
    return [pairs componentsJoinedByString:@"&"];
}

#pragma mark - HPPRLoginProviderDelegate

- (void)didLogoutWithProvider:(HPPRLoginProvider *)loginProvider
{
    [self clearCache];
}


@end

