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

NSString * const kSocialNetworkKey = @"social-network";
NSString * const kIncludeLoginKey = @"include-login";

@interface PGSocialSource ()

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *menuIcon;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) HPPRLoginProvider *loginProvider;
@property (nonatomic, strong) HPPRSelectPhotoProvider *photoProvider;

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
            self.needsSignIn = YES;
            self.loginProvider = [HPPRFacebookLoginProvider sharedInstance];
            self.photoProvider = [HPPRFacebookPhotoProvider sharedInstance];
            break;
        case PGSocialSourceTypeFlickr:
            self.icon = [UIImage imageNamed:@"Flickr"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Flickr", @"Social source title for Flickr");
            self.needsSignIn = YES;
            self.loginProvider = [HPPRFlickrLoginProvider sharedInstance];
            self.photoProvider = [HPPRFlickrPhotoProvider sharedInstance];
            break;
        case PGSocialSourceTypeInstagram:
            self.icon = [UIImage imageNamed:@"Instagram_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Instagram", @"Social source title for Instagram");
            self.needsSignIn = YES;
            self.loginProvider = [HPPRInstagramLoginProvider sharedInstance];
            self.photoProvider = [HPPRInstagramPhotoProvider sharedInstance];
            break;
        case PGSocialSourceTypeLocalPhotos:
            self.icon = [UIImage imageNamed:@"Photos_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Camera Roll", @"Social source title for Camera Roll");
            self.needsSignIn = NO;
            self.photoProvider = [HPPRCameraRollPhotoProvider sharedInstance];
            break;
        case PGSocialSourceTypeWeiBo:
            self.icon = [UIImage imageNamed:@"WeiBo_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"WeiBo", @"Social source title for WeiBo");
            self.needsSignIn = YES;
            break;
        case PGSocialSourceTypeQzone:
            self.icon = [UIImage imageNamed:@"Qzone_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Qzone", @"Social source title for Qzone");
            self.needsSignIn = YES;
            break;
        case PGSocialSourceTypePitu:
            self.icon = [UIImage imageNamed:@"Pitu_C"];
            self.menuIcon = self.icon;
            self.title = NSLocalizedString(@"Pitu", @"Social source title for Pitu");
            self.needsSignIn = NO;
            break;

        default:
            break;
    }
}

@end
