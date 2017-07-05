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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HPPRSelectPhotoProvider.h"

@interface HPPRInstagramPhotoProvider : HPPRSelectPhotoProvider

+ (HPPRInstagramPhotoProvider *)sharedInstance;

- (void)initForStandardDisplay;
- (void)initWithHashtag:(NSString *)hashTag withNumPosts:(NSNumber *)numPosts;
- (void)initWithUsername:(NSString *)displayName andUserId:(NSNumber *)userId andImage:(UIImage *)userImage;
- (NSArray *)filterRecordsForDate:(NSDate *)filterDate andRecords:(NSArray *)records;
- (NSArray *)filterRecordsForLocation:(CLLocation *)filterLocation distance:(int)distance andRecords:(NSArray *)records;

@end
