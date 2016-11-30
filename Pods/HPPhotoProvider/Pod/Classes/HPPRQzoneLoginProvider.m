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

#define kResponse @"kResponse"

@interface HPPRQzoneLoginProvider() <TencentLoginDelegate, TencentApiInterfaceDelegate, TencentWebViewDelegate>

@property (nonatomic, strong) TencentOAuth *loginManager;
@property (nonatomic, strong) void (^loginCompletion)(BOOL loggedIn, NSError *error);
@property (nonatomic, strong) void (^albumsCompletion)(NSDictionary *albums, NSError *error);
@property (nonatomic, strong) void (^photosCompletion)(NSDictionary *photos, NSError *error);

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
        BOOL isAccessTokenValid = (self.loginManager.accessToken && 0) != self.loginManager.accessToken.length;
        
        if (isAccessTokenValid) {
            completion(isAccessTokenValid, nil);
        } else {
            self.loginManager = [[TencentOAuth alloc] initWithAppId:@"222222" andDelegate:self];
            self.loginManager.redirectURI = @"www.qq.com";
            
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

- (BOOL)handleApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation
{
   return [TencentOAuth HandleOpenURL:url];
}

- (void)tencentDidLogin
{
    if (self.loginCompletion) {
        self.loginCompletion((self.loginManager.accessToken && 0) != self.loginManager.accessToken.length, nil);
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

#pragma mark Tencent Request Methods

- (void)listAlbums:(void (^)(NSDictionary *albums, NSError *error))completion
{
    [self.loginManager getListAlbum];
    self.albumsCompletion = completion;
}

- (void)listPhotosForAlbum:(NSString *)albumId completion:(void (^)(NSDictionary *photos, NSError *error))completion
{
    TCListPhotoDic *params = [TCListPhotoDic dictionary];
    params.paramAlbumid = albumId;
    self.photosCompletion = completion;
    
    if (![self.loginManager getListPhotoWithParams:params]) {
        completion(nil, [NSError errorWithDomain:nil code:1 userInfo:nil]);
    }
}

// _paramAlbumid	__NSCFString *	@"V10nmuBB3TGpPQ"	0x000000017003ccc0

- (void)getListAlbumResponse:(APIResponse *)response
{
    if (response) {
        NSDictionary *albums = [[response jsonResponse] objectForKey:@"album"];
        self.albumsCompletion(albums, nil);
    } else {
        self.albumsCompletion(nil, nil);
    }
}

- (void)getListPhotoResponse:(APIResponse *)response
{
    self.photosCompletion([[response jsonResponse] objectForKey:@"photos"], nil);
}

@end

