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

#import "PGLandingPageViewController.h"

#import <HPPRSelectPhotoCollectionViewController.h>
#import "PGWebViewerViewController.h"
#import "SWRevealViewController.h"
#import "UIColor+Style.h"
#import "PGTermsAttributedLabel.h"
#import "PGPreviewViewController.h"
#import "PGCameraManager.h"
#import "UIViewController+trackable.h"
#import "PGAnalyticsManager.h"
#import "PGMediaNavigation.h"

const NSInteger PGLandingPageViewControllerCollectionViewBottomInset = 120;

@interface PGLandingPageViewController () <UIGestureRecognizerDelegate, HPPRSelectPhotoCollectionViewControllerDelegate>

@property (strong, nonatomic) UIView *dropDownContainerView;

@end

@implementation PGLandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       
    UIBarButtonItem *hamburgerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStylePlain target:self.revealViewController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = hamburgerButtonItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_SWIPE_COACH_MARKS_NOTIFICATION object:nil];
}

- (void)setLinkForLabel:(TTTAttributedLabel *)label range:(NSRange)range
{
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    [linkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [linkAttributes setValue:(__bridge id)[[UIColor HPLinkColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    label.linkAttributes = linkAttributes;
    label.activeLinkAttributes = linkAttributes;
    
    label.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    label.delegate = self;
    label.text = label.text;
    
    [label addLinkToURL:[NSURL URLWithString:@"#"] withRange:range];
}

- (void)showLogin
{
    NSLog(@"Need to implement subclass showLogin function");
}

- (void)showAlbums
{
    HPPRSelectPhotoProvider *provider = [self albumsPhotoProvider];

    if (provider) {
        if (self.albumsViewController) {
            [self hideAlbums];
        } else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
            self.albumsViewController = [storyboard instantiateViewControllerWithIdentifier:@"PGSelectAlbumDropDownViewController"];
            self.albumsViewController.delegate = self;
            self.albumsViewController.provider = provider;

            CGRect bounds = self.view.bounds;
            CGRect frameUp = CGRectMake(0, 0 - bounds.size.height, bounds.size.width, bounds.size.height);
            CGRect frameDown = CGRectMake(0, 0, bounds.size.width, bounds.size.height);

            self.dropDownContainerView = [[UIView alloc] initWithFrame:frameUp];
            self.dropDownContainerView.backgroundColor = [UIColor blackColor];

            [self.navigationController.topViewController addChildViewController:self.albumsViewController];
            self.albumsViewController.view.frame = CGRectMake(0, 0, self.dropDownContainerView.bounds.size.width, self.dropDownContainerView.bounds.size.height - 2);

            [self.dropDownContainerView addSubview:self.albumsViewController.view];
            [self.navigationController.topViewController.view addSubview:self.dropDownContainerView];

            [UIView animateWithDuration:0.5
                                  delay:0.0
                 usingSpringWithDamping:1.0
                  initialSpringVelocity:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.dropDownContainerView.frame = frameDown;
                             }
                             completion:nil];
        }
    }
}

- (void)hideAlbums {
    if (self.albumsViewController) {
        self.albumsViewController = nil;

        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect bounds = self.view.bounds;
                             CGRect frame = CGRectMake(0, 0 - bounds.size.height, bounds.size.width, bounds.size.height);
                             self.dropDownContainerView.frame = frame;
                         } completion:^(BOOL finished) {
                             [self.dropDownContainerView removeFromSuperview];
                         }];

        if ([self.delegate respondsToSelector:@selector(landingPageViewController:didShowViewController:)]) {
            [self.delegate landingPageViewController:self didShowViewController:self.photoCollectionViewController];
        }
    }
}

- (HPPRSelectPhotoProvider *)albumsPhotoProvider {
    return nil;
}

- (void)willSignInToSocialSource:(PGSocialSource *)socialSource notifyDelegate:(BOOL)notifyDelegate {
    if (notifyDelegate) {
        if ([self.delegate respondsToSelector:@selector(landingPageViewController:willSignInToSocialSource:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate landingPageViewController:self willSignInToSocialSource:socialSource];
            });
        }
    }
}

- (void)didSignInToSocialSource:(PGSocialSource *)socialSource notifyDelegate:(BOOL)notifyDelegate {
    if (notifyDelegate) {
        if ([self.delegate respondsToSelector:@selector(landingPageViewController:didSignInToSocialSource:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate landingPageViewController:self didSignInToSocialSource:socialSource];
            });
        }
    }
}

- (void)didSignOutToSocialSource:(PGSocialSource *)socialSource notifyDelegate:(BOOL)notifyDelegate {
    if (notifyDelegate) {
        if ([self.delegate respondsToSelector:@selector(landingPageViewController:didSignOutToSocialSource:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate landingPageViewController:self didSignOutToSocialSource:socialSource];
            });
        }
    }
}

- (void)didFailSignInToSocialSource:(PGSocialSource *)socialSource notifyDelegate:(BOOL)notifyDelegate {
    if (notifyDelegate) {
        if ([self.delegate respondsToSelector:@selector(landingPageViewController:didFailSignInToSocialSource:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate landingPageViewController:self didFailSignInToSocialSource:socialSource];
            });
        }
    }
}

- (void)willSignInToSocialSource:(PGSocialSource *)socialSource {
    [self willSignInToSocialSource:socialSource notifyDelegate:YES];
}

- (void)didSignInToSocialSource:(PGSocialSource *)socialSource {
    [self didSignInToSocialSource:socialSource notifyDelegate:YES];
}

- (void)didSignOutToSocialSource:(PGSocialSource *)socialSource {
    [self didSignOutToSocialSource:socialSource notifyDelegate:YES];
}

- (void)didFailSignInToSocialSource:(PGSocialSource *)socialSource {
    [self didFailSignInToSocialSource:socialSource notifyDelegate:YES];
}

- (void)presentPhotoGalleryWithSettings:(void (^)(HPPRSelectPhotoCollectionViewController *))settings {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];

    self.photoCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
    self.photoCollectionViewController.delegate = self;

    if (settings) {
        settings(self.photoCollectionViewController);
    }

    [self.navigationController pushViewController:self.photoCollectionViewController animated:YES];

    if ([self.delegate respondsToSelector:@selector(landingPageViewController:didShowViewController:)]) {
        [self.delegate landingPageViewController:self didShowViewController:self.photoCollectionViewController];
    }
}

- (void)showNoConnectionAvailableAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Connection Available", nil)
                                                    message:NSLocalizedString(@"Please connect to a data source.\nYou can also use your device photos.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGTermsNavigationController"];

    navigationController.topViewController.trackableScreenName = @"Terms of Service Screen";    
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - Photo Collection Camera Delegate Methods

- (void)selectPhotoCollectionViewControllerDidSelectCamera:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewControllerCamera = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    
    [[PGAnalyticsManager sharedManager] trackCameraGallerySelect];
    [self presentViewController:previewViewControllerCamera animated:YES completion:nil];
}

- (AVCaptureDevicePosition)cameraPosition
{
    return [PGCameraManager sharedInstance].lastDeviceCameraPosition;
}


#pragma mark - HPPRSelectPhotoCollectionViewControllerDelegate

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didSelectImage:(UIImage *)image source:(NSString *)source media:(HPPRMedia *)media {

}

- (void)selectPhotoCollectionViewControllerDidInitiateMultiSelectMode:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController {
    if ([self.delegate respondsToSelector:@selector(landingPageViewControllerDidInitiateSelection:)]) {
        [self.delegate landingPageViewControllerDidInitiateSelection:self];
    }
}

#pragma mark - PGSelectAlbumDropDownViewControllerDelegate

- (void)selectAlbumDropDownController:(PGSelectAlbumDropDownViewController *)viewController didSelectAlbum:(HPPRAlbum *)album
{
    self.photoCollectionViewController.provider.album = album;
    [self.photoCollectionViewController refresh];

    [self hideAlbums];
}


@end
