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
#import <imglyKit/imglyKit-Swift.h>
#import "PGEmbellishmentMetric.h"
#import "PGEmbellishmentMetricsManager.h"

@interface PGImglyManager : NSObject

extern NSString * const kPGImglyManagerStickersChangedNotification;

@property (strong, nonatomic) IMGLYPhotoEditViewController *photoEditViewController;

- (IMGLYConfiguration *)imglyConfigurationWithEmbellishmentManager:(PGEmbellishmentMetricsManager *)embellishmentMetricsManager;
- (IMGLYPhotoEffect *)imglyFilterByName:(NSString *)name;

- (NSArray<IMGLYBoxedMenuItem *> *)menuItemsWithConfiguration:(IMGLYConfiguration *)configuration;

@end
