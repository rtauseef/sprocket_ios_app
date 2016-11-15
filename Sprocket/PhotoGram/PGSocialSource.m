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

#import "PGSocialSource.h"

@interface PGSocialSource ()

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *menuIcon;
@property (nonatomic, copy) NSString *title;

@end

@implementation PGSocialSource

- (instancetype)initWithSocialSourceType:(PGSocialSourceType)type
{
    self = [super init];

    if (self) {
        self.type = type;
    }

    return self;
}

- (void)setType:(PGSocialSourceType)type
{
    _type = type;

    [self setupSocialSource];
}


#pragma mark - Private

- (void)setupSocialSource
{
    switch (self.type) {
        case PGSocialSourceTypeFacebook:
            self.icon = [UIImage imageNamed:@"facebook_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Facebook", @"Social source title for Facebook");
            break;
        case PGSocialSourceTypeFlickr:
            self.icon = [UIImage imageNamed:@"Flickr"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Flickr", @"Social source title for Flickr");
            break;
        case PGSocialSourceTypeInstagram:
            self.icon = [UIImage imageNamed:@"Instagram_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Instagram", @"Social source title for Instagram");
            break;
        case PGSocialSourceTypeLocalPhotos:
            self.icon = [UIImage imageNamed:@"Photos_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Camera Roll", @"Social source title for Camera Roll");
            break;
        case PGSocialSourceTypeWeiBo:
            self.icon = [UIImage imageNamed:@"WeiBo_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"WeiBo", @"Social source title for WeiBo");
            break;
        case PGSocialSourceTypeQzone:
            self.icon = [UIImage imageNamed:@"Qzone_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Qzone", @"Social source title for Qzone");
            break;
        case PGSocialSourceTypePitu:
            self.icon = [UIImage imageNamed:@"Pitu_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Pitu", @"Social source title for Pitu");
            break;

        default:
            break;
    }
}

@end
