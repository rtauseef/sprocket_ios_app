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

@interface PGLandingPageViewController : UIViewController <TTTAttributedLabelDelegate, PGSelectAlbumDropDownViewControllerDelegate>

@property (strong, nonatomic) PGSelectAlbumDropDownViewController *albumsViewController;
@property (strong, nonatomic) HPPRSelectPhotoCollectionViewController *photoCollectionViewController;
@property (weak, nonatomic) id<PGLandingPageViewControllerDelegate> delegate;

- (void)setLinkForLabel:(TTTAttributedLabel *)label range:(NSRange)range;
- (void)showLogin;
- (void)showNoConnectionAvailableAlert;
- (void)showAlbums;
- (HPPRSelectPhotoProvider *)albumsPhotoProvider;

- (void)willSignInToSocialSource:(PGSocialSource *)socialSource notifyDelegate:(BOOL)notifyDelegate;
- (void)didSignInToSocialSource:(PGSocialSource *)socialSource notifyDelegate:(BOOL)notifyDelegate;
- (void)didSignOutToSocialSource:(PGSocialSource *)socialSource notifyDelegate:(BOOL)notifyDelegate;
- (void)didFailSignInToSocialSource:(PGSocialSource *)socialSource notifyDelegate:(BOOL)notifyDelegate;

- (void)willSignInToSocialSource:(PGSocialSource *)socialSource;
- (void)didSignInToSocialSource:(PGSocialSource *)socialSource;
- (void)didSignOutToSocialSource:(PGSocialSource *)socialSource;
- (void)didFailSignInToSocialSource:(PGSocialSource *)socialSource;

- (void)presentPhotoGalleryWithSettings:(void (^)(HPPRSelectPhotoCollectionViewController *viewController))settings;

@end

@protocol PGLandingPageViewControllerDelegate <NSObject>

@optional

- (void)landingPageViewController:(PGLandingPageViewController *)landingViewController willSignInToSocialSource:(PGSocialSource *)socialSource;
- (void)landingPageViewController:(PGLandingPageViewController *)landingViewController didSignInToSocialSource:(PGSocialSource *)socialSource;
- (void)landingPageViewController:(PGLandingPageViewController *)landingViewController didSignOutToSocialSource:(PGSocialSource *)socialSource;
- (void)landingPageViewController:(PGLandingPageViewController *)landingViewController didFailSignInToSocialSource:(PGSocialSource *)socialSource;

- (void)landingPageViewController:(PGLandingPageViewController *)landingViewController didShowViewController:(UIViewController *)viewController;

@end
