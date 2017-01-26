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

#import <MobileCoreServices/MobileCoreServices.h>
#import <HPPR.h>
#import <HPPRSelectAlbumTableViewController.h>
#import <HPPRSelectPhotoCollectionViewController.h>
#import "PGCameraRollLandingPageViewController.h"
#import "UIViewController+Trackable.h"
#import "PGPreviewViewController.h"
#import "PGImagePickerLandscapeSupportController.h"
#import "PGAnalyticsManager.h"
#import "HPPRCameraRollLoginProvider.h"
#import "HPPRCameraRollPhotoProvider.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Animations.h"
#import "SWRevealViewController.h"

NSString * const kCameraRollUserName = @"CameraRollUserName";
NSString * const kCameraRollUserId = @"CameraRollUserId";

@interface PGCameraRollLandingPageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate>

@property (strong, nonatomic) void(^accessCompletion)(BOOL granted);
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIImage *selectedPhoto;

@end

@implementation PGCameraRollLandingPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Camera Roll Landing Page Screen";
    
    self.view.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.containerView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.termsLabel.delegate = self;
    
    [self checkCameraRollAndAlbums:NO];
}

- (IBAction)signInButtonTapped:(id)sender
{
    [[HPPRCameraRollLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self checkCameraRollAndAlbums:NO];
            [[PGAnalyticsManager sharedManager] trackAuthRequestActivity:kEventAuthRequestOkAction
                                                                  device:kEventAuthRequestPhotosLabel];
        } else {
            [[PGAnalyticsManager sharedManager] trackAuthRequestActivity:kEventAuthRequestDeniedAction
                                                                  device:kEventAuthRequestPhotosLabel];
        }
    }];
}

- (void)showAlbums
{
    [self checkCameraRollAndAlbums:YES];
}

- (void)checkCameraRollAndAlbums:(BOOL)forAlbums
{
    UIActivityIndicatorView *spinner = [self.view addSpinner];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    [[HPPRCameraRollLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
            
            HPPRCameraRollPhotoProvider *provider = [HPPRCameraRollPhotoProvider sharedInstance];
            UIViewController *vc = nil;
            if (forAlbums) {
                vc = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectAlbumTableViewController"];
                ((HPPRSelectAlbumTableViewController *)vc).delegate = self;
                ((HPPRSelectAlbumTableViewController *)vc).provider = provider;

            } else {
                vc = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
                ((HPPRSelectPhotoCollectionViewController *)vc).delegate = self;
                ((HPPRSelectPhotoCollectionViewController *)vc).provider = provider;
                ((HPPRSelectPhotoCollectionViewController *)vc).cameraButtonInCollectionView = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [spinner removeFromSuperview];
                [self.navigationController pushViewController:vc animated:YES];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner removeFromSuperview];
            });
        }
    }];
}

#pragma mark - HPPRSelectPhotoCollectionViewControllerDelegate

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didSelectImage:(UIImage *)image source:(NSString *)source media:(HPPRMedia *)media
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.selectedPhoto = image;
    previewViewController.source = source;
    
    HPPRCameraRollPhotoProvider *provider = [HPPRCameraRollPhotoProvider sharedInstance];
    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:kCameraRollUserName userId:kCameraRollUserId];
    
    [self presentViewController:previewViewController animated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
}

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didChangeViewMode:(HPPRSelectPhotoCollectionViewMode)viewMode
{
    NSString *mode;
    if (viewMode == HPPRSelectPhotoCollectionViewModeGrid) {
        mode = kPhotoCollectionViewModeGrid;
    } else {
        mode = kPhotoCollectionViewModeList;
    }

    [[PGAnalyticsManager sharedManager] trackPhotoCollectionViewMode:mode];
}

- (void)selectPhotoCollectionViewControllerDidSelectCamera:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewControllerCamera = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    
    [self presentViewController:previewViewControllerCamera animated:YES completion:nil];
}

- (UIEdgeInsets)collectionViewContentInset {
    return UIEdgeInsetsMake(0, 0, PGLandingPageViewControllerCollectionViewBottomInset, 0);
}

@end
