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
@property (nonatomic, assign) BOOL hasFolders;
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
    self.icon = nil;
    self.menuIcon = nil;
    self.title = nil;
    self.hasFolders = NO;
    self.needsSignIn = NO;
    self.loginProvider = nil;
    self.photoProvider = nil;

    switch (self.type) {
        case PGSocialSourceTypeFacebook:
            self.icon = [UIImage imageNamed:@"facebook_C"];
            self.menuIcon = self.icon;
            self.hasFolders = YES;
            self.title = NSLocalizedString(@"Facebook", @"Social source title for Facebook");
            self.needsSignIn = YES;
            self.loginProvider = [HPPRFacebookLoginProvider sharedInstance];
            self.photoProvider = [HPPRFacebookPhotoProvider sharedInstance];
            self.photoProvider.showCameraButtonInCollectionView = YES;
            break;
        case PGSocialSourceTypeFlickr:
            self.icon = [UIImage imageNamed:@"Flickr"];
            self.menuIcon = self.icon;
            self.hasFolders = YES;
            self.title = NSLocalizedString(@"Flickr", @"Social source title for Flickr");
            self.needsSignIn = YES;
            self.loginProvider = [HPPRFlickrLoginProvider sharedInstance];
            self.photoProvider = [HPPRFlickrPhotoProvider sharedInstance];
            self.photoProvider.showCameraButtonInCollectionView = YES;
            break;
        case PGSocialSourceTypeInstagram:
            self.icon = [UIImage imageNamed:@"Instagram_C"];
            self.menuIcon = self.icon;
            self.hasFolders = NO;
            self.title = NSLocalizedString(@"Instagram", @"Social source title for Instagram");
            self.needsSignIn = YES;
            self.loginProvider = [HPPRInstagramLoginProvider sharedInstance];
            self.photoProvider = [HPPRInstagramPhotoProvider sharedInstance];
            self.photoProvider.showCameraButtonInCollectionView = YES;
            break;
        case PGSocialSourceTypeLocalPhotos:
            self.icon = [UIImage imageNamed:@"Photos_C"];
            self.menuIcon = self.icon;
            self.hasFolders = YES;
            self.title = NSLocalizedString(@"Camera Roll", @"Social source title for Camera Roll");
            self.needsSignIn = NO;
            self.loginProvider = [HPPRCameraRollLoginProvider sharedInstance];
            self.photoProvider = [HPPRCameraRollPhotoProvider sharedInstance];
            self.photoProvider.showCameraButtonInCollectionView = YES;
            break;
        case PGSocialSourceTypeWeiBo:
            self.icon = [UIImage imageNamed:@"WeiBo_C"];
            self.menuIcon = self.icon;
            self.hasFolders = NO; // Still TBD
            self.title = NSLocalizedString(@"WeiBo", @"Social source title for WeiBo");
            self.needsSignIn = YES;
            break;
        case PGSocialSourceTypeQzone:
            self.icon = [UIImage imageNamed:@"Qzone_C"];
            self.menuIcon = self.icon;
            self.hasFolders = YES;
            self.title = NSLocalizedString(@"Qzone", @"Social source title for Qzone");
            self.needsSignIn = YES;
            self.loginProvider = [HPPRQzoneLoginProvider sharedInstance];
            self.photoProvider = [HPPRQzonePhotoProvider sharedInstance];
            self.photoProvider.showCameraButtonInCollectionView = YES;
            break;
        case PGSocialSourceTypePitu:
            self.icon = [UIImage imageNamed:@"Pitu_C"];
            self.menuIcon = self.icon;
            self.hasFolders = NO;
            self.title = NSLocalizedString(@"Pitu", @"Social source title for Pitu");
            self.needsSignIn = NO;
            self.loginProvider = [HPPRPituLoginProvider sharedInstance];
            self.photoProvider = [HPPRPituPhotoProvider sharedInstance];
            self.photoProvider.showCameraButtonInCollectionView = YES;
            break;
        case PGSocialSourceTypeLink:
            self.icon = [UIImage imageNamed:@"linkReaderScan"];
        default:
            break;
    }
}

@end
