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

typedef NS_OPTIONS(NSUInteger, PGSocialSourceType) {
    PGSocialSourceTypeLocalPhotos = 1 << 0, // 1
    PGSocialSourceTypeFacebook    = 1 << 1, // 2
    PGSocialSourceTypeInstagram   = 1 << 2, // 4
    PGSocialSourceTypeFlickr      = 1 << 3, // 8
    PGSocialSourceTypePitu        = 1 << 4, // 16
    PGSocialSourceTypeWeiBo       = 1 << 5, // 32
    PGSocialSourceTypeQzone       = 1 << 6  // 64
};

@interface PGSocialSource : NSObject

@property (nonatomic, assign) PGSocialSourceType type;
@property (nonatomic, strong, readonly) UIImage *icon;
@property (nonatomic, strong, readonly) UIImage *menuIcon;
@property (nonatomic, readonly) NSString *title;

- (instancetype)initWithSocialSourceType:(PGSocialSourceType)type;

@end
