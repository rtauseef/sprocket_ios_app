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

@interface HPPRInstagramUserMedia : NSObject

+ (void)userMediaRecentWithId:(NSString *)userId nextMaxId:(NSString *)nextMaxId completion:(void (^)(NSDictionary *instagramPage, NSError *error))completion;
+ (void)userMediaFeedWithId:(NSString *)userId nextMaxId:(NSString *)nextMaxId completion:(void (^)(NSDictionary *instagramPage, NSError *error))completion;

+ (void)userFirstImageWithId:(NSString *)userId completion:(void (^)(UIImage *image))completion;

@end
