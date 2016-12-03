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

#import "TencentOpenAPI/TencentOAuth.h"
#import "HPPRQzoneLoginProvider.h"
#import "HPPRQzoneAlbum.h"
#import "HPPR.h"

#define kResponse @"kResponse"

NSString * const kQzoneProviderName = @"Qzone";

@interface HPPRQzoneLoginProvider() <TencentLoginDelegate, TencentApiInterfaceDelegate, TencentWebViewDelegate>

@property (nonatomic, strong) TencentOAuth *loginManager;
@property (nonatomic, strong) void (^loginCompletion)(BOOL loggedIn, NSError *error);
@property (nonatomic, strong) void (^logoutCompletion)(BOOL loggedIn, NSError *error);
@property (nonatomic, strong) void (^albumsCompletion)(NSDictionary *albums, NSError *error);
@property (nonatomic, strong) void (^photosCompletion)(NSDictionary *photos, NSError *error);
@property (nonatomic, strong) NSMutableArray *allPhotos;
@property (nonatomic, assign) NSUInteger numberOfAlbums;
@property (nonatomic, assign) NSUInteger albumsCounter;

@end

@implementation HPPRQzoneLoginProvider


#pragma mark - Initialization

+ (HPPRQzoneLoginProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRQzoneLoginProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRQzoneLoginProvider alloc] init];
    });
    return sharedInstance;
}

- (void)loginWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if ([self connectedToInternet:completion]) {
        
        if ([self isAccesTokenValid]) {
            completion([self isAccesTokenValid], nil);
        } else {
            self.loginManager = [[TencentOAuth alloc] initWithAppId:[HPPR sharedInstance].qzoneAppId andDelegate:self];
            self.loginManager.redirectURI = [HPPR sharedInstance].qzoneRedirectURL;
            
            NSArray* permissions = @[kOPEN_PERMISSION_GET_USER_INFO,
                                    kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                    kOPEN_PERMISSION_GET_INFO,
                                    kOPEN_PERMISSION_GET_OTHER_INFO,
                                    kOPEN_PERMISSION_LIST_ALBUM];
            
            [self.loginManager authorize:permissions inSafari:NO];
            
            self.loginCompletion = completion;
        }
    } else {
        NSLog(@"Not Connected to Internet");
    }
}

- (void)checkStatusWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if( [self connectedToInternet:completion] ) {
        if (completion) {
            completion([self isAccesTokenValid], nil);
        }
    }
}

- (BOOL)isAccesTokenValid
{
    return ((self.loginManager.accessToken && 0) != self.loginManager.accessToken.length);
}

- (void)logoutWithCompletion:(void (^)(BOOL loggedOut, NSError *error))completion
{
    self.logoutCompletion = completion;
    
    [self.loginManager logout:self];
}

- (NSString *)providerName
{
    return kQzoneProviderName;
}

- (BOOL)handleApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation
{
   return [TencentOAuth HandleOpenURL:url];
}

- (void)tencentDidLogin
{
    if (self.loginCompletion) {
        [self.loginManager getUserInfo];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (self.loginCompletion) {
        self.loginCompletion(NO, nil);
    }
}

- (void)tencentDidNotNetWork
{
    if (self.loginCompletion) {
        self.loginCompletion(NO, nil);
    }
}

- (void)tencentDidLogout
{
    if (self.logoutCompletion) {
        [self notifyLogout];
        self.logoutCompletion(YES, nil);
    }
}


#pragma mark Tencent Request Methods

- (void)listAlbums:(void (^)(NSDictionary *albums, NSError *error))completion
{
    [self.loginManager getListAlbum];
    self.albumsCompletion = completion;
}

- (void)listPhotosForAlbum:(NSString *)albumId completion:(void (^)(NSDictionary *photos, NSError *error))completion
{
    if (albumId) {
        TCListPhotoDic *params = [TCListPhotoDic dictionary];
        params.paramAlbumid = albumId;
        self.photosCompletion = completion;
        
        if (![self.loginManager getListPhotoWithParams:params]) {
            completion(nil, nil);
        }
    } else {
        [self listAlbums:^(NSDictionary *albums, NSError *error) {
            if (error || !albums) {
                NSLog(@"QZONE ALBUMS ERROR\n%@", error);
                if (completion) {
                    completion(nil, error);
                }
            } else {
                self.photosCompletion = completion;
                self.numberOfAlbums = albums.count;
                self.albumsCounter = 0;
                self.allPhotos = [NSMutableArray array];
                
                for (NSDictionary *album in albums) {
                    HPPRQzoneAlbum *qzoneAlbum = [[HPPRQzoneAlbum alloc] initWithAttributes:album];
                    TCListPhotoDic *params = [TCListPhotoDic dictionary];
                    params.paramAlbumid = qzoneAlbum.objectID;
                    
                    [self.loginManager getListPhotoWithParams:params];
                }
            }
        }];
    }
}


- (void)getUserInfoResponse:(APIResponse *)response
{
    self.user = [response jsonResponse];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_PROVIDER_LOGIN_SUCCESS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[self providerName] forKey:kQzoneProviderName]];
    self.loginCompletion([self isAccesTokenValid], nil);
}

- (void)getListAlbumResponse:(APIResponse *)response
{
    if (response) {
        NSMutableArray *albums = [[response jsonResponse] objectForKey:@"album"];
        NSInteger totalPhotos = 0;
        
        if (albums) {
            for (NSDictionary *album in albums) {
                totalPhotos += [[album objectForKey:@"picnum"] integerValue];
            }
            
            NSMutableDictionary *allPhotosAlbum = [[NSMutableDictionary alloc] initWithCapacity:1];
            [allPhotosAlbum setObject:NSLocalizedString(@"All Photos", nil) forKey:@"name"];
            [allPhotosAlbum setObject:[NSNumber numberWithInteger:totalPhotos] forKey:@"picnum"];
            [allPhotosAlbum setObject:[albums[albums.count - 1] objectForKey:@"coverurl"] forKey:@"coverurl"];
            
            [albums insertObject:allPhotosAlbum atIndex:0];
        }
        
        self.albumsCompletion(albums, nil);
    } else {
        self.albumsCompletion(nil, nil);
    }
}

- (void)getListPhotoResponse:(APIResponse *)response
{
    NSArray *photos = (NSArray *)[[response jsonResponse] objectForKey:@"photos"];
    
    if (self.numberOfAlbums) {
        [self.allPhotos addObjectsFromArray:photos];
        self.albumsCounter++;
        
        if (self.numberOfAlbums == self.albumsCounter) {
            self.numberOfAlbums = 0;
            self.albumsCounter = 0;
            self.photosCompletion(self.allPhotos, nil);
            self.allPhotos = nil;
        }
    } else {
        self.photosCompletion(photos, nil);
    }
}

@end

