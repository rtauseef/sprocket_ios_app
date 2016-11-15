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

typedef NS_ENUM(NSUInteger, PGSocialSourceType) {
    PGSocialSourceTypeLocalPhotos = 0,
    PGSocialSourceTypeFacebook,
    PGSocialSourceTypeInstagram,
    PGSocialSourceTypeFlickr,
    PGSocialSourceTypePitu,
    PGSocialSourceTypeWeiBo,
    PGSocialSourceTypeQzone
};

@interface PGSocialSource : NSObject

@property (nonatomic, assign) PGSocialSourceType type;
@property (nonatomic, strong, readonly) UIImage *icon;
@property (nonatomic, strong, readonly) UIImage *menuIcon;
@property (nonatomic, readonly) NSString *title;

- (instancetype)initWithSocialSourceType:(PGSocialSourceType)type;

@end
