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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HPPRSelectPhotoProvider.h"

@interface HPPRFacebookPhotoProvider : HPPRSelectPhotoProvider

@property (strong, nonatomic) NSDictionary *user;

+ (HPPRFacebookPhotoProvider *)sharedInstance;

- (void)photoByID:(NSString *)photoID withRefresh:(BOOL)refresh andCompletion:(void (^)(NSDictionary *photoInfo, NSError *error))completion;
- (void)userInfoWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSDictionary *userInfo, NSError *error))completion;

- (NSString *)urlForPhoto:(NSDictionary *)photoInfo withHeight:(NSUInteger)height;
- (NSString *)urlForSmallestPhoto:(NSDictionary *)photoInfo;
- (NSString *)urlForLargestPhoto:(NSDictionary *)photoInfo;
- (NSString *)urlForVideoPhoto:(NSDictionary *)photoInfo;
- (NSString *)urlForVideoThumbnail:(NSDictionary *)photoInfo;

@end
