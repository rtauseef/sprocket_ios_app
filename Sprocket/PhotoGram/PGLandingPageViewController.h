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

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel.h>
#import <HPPRLoginProvider.h>
#import <HPPRError.h>
#import "PGSocialSource.h"
#import "PGSelectAlbumDropDownViewController.h"

extern const NSInteger PGLandingPageViewControllerCollectionViewBottomInset;

@protocol PGLandingPageViewControllerDelegate;

@interface PGLandingPageViewController : UIViewController <TTTAttributedLabelDelegate>

@property (strong, nonatomic) PGSelectAlbumDropDownViewController *albumsViewController;
@property (strong, nonatomic) HPPRSelectPhotoCollectionViewController *photoCollectionViewController;
@property (weak, nonatomic) id<PGLandingPageViewControllerDelegate> delegate;

- (void)setLinkForLabel:(TTTAttributedLabel *)label range:(NSRange)range;
- (void)showLogin;
- (void)showNoConnectionAvailableAlert;
- (void)showAlbums;
- (HPPRSelectPhotoProvider *)albumsPhotoProvider;

- (void)presentPhotoGalleryWithSettings:(void (^)(HPPRSelectPhotoCollectionViewController *viewController))settings;

@end

@protocol PGLandingPageViewControllerDelegate <NSObject>

@optional

- (void)landingPageViewController:(PGLandingPageViewController *)landingViewController didShowViewController:(UIViewController *)viewController;

@end
