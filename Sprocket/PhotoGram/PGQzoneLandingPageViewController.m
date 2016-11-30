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

#import "PGQzoneLandingPageViewController.h"

#import "HPPRSelectPhotoCollectionViewController.h"
#import <HPPRSelectAlbumTableViewController.h>
#import <HPPRSelectPhotoCollectionViewController.h>
#import "HPPRQzoneLoginProvider.h"
#import "HPPRQzonePhotoProvider.h"
#import "PGAnalyticsManager.h"
#import "PGPreviewViewController.h"
#import "UIViewController+Trackable.h"
#import "UIView+Animations.h"
#import "SWRevealViewController.h"

#import <HPPR.h>

@interface PGQzoneLandingPageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation PGQzoneLandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.trackableScreenName = @"Qzone Landing Page Screen";

    self.view.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.signInView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.termsLabel.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
}
#pragma mark - PhotoProvider methods

- (void)showAlbums
{
    [self checkCameraRollAndAlbums:YES];
}

- (void)checkCameraRollAndAlbums:(BOOL)forAlbums
{
    UIActivityIndicatorView *spinner = [self.view addSpinner];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
    
    HPPRQzonePhotoProvider *provider = [HPPRQzonePhotoProvider sharedInstance];
    UIViewController *vc = nil;
    if (forAlbums) {
        vc = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectAlbumTableViewController"];
        ((HPPRSelectAlbumTableViewController *)vc).delegate = self;
        ((HPPRSelectAlbumTableViewController *)vc).provider = provider;
        
    } else {
        vc = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
        ((HPPRSelectPhotoCollectionViewController *)vc).delegate = self;
        ((HPPRSelectPhotoCollectionViewController *)vc).provider = provider;
        ((HPPRSelectPhotoCollectionViewController *)vc).customNoPhotosMessage = NSLocalizedString(@"No Qzone app images found", @"Message displayed when no images from the Qzone app can be found");
    }
    
    UIBarButtonItem *hamburgerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStylePlain target:self.revealViewController action:@selector(revealToggle:)];
    
    vc.navigationItem.leftBarButtonItem = hamburgerButtonItem;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [spinner removeFromSuperview];
        [self.navigationController pushViewController:vc animated:YES];
    });
}

#pragma mark - Notifications

- (void)handleMenuOpenedNotification:(NSNotification *)notification
{
    self.signInButton.userInteractionEnabled = NO;
    self.termsLabel.userInteractionEnabled = NO;
}

- (void)handleMenuClosedNotification:(NSNotification *)notification
{
    self.signInButton.userInteractionEnabled = YES;
    self.termsLabel.userInteractionEnabled = YES;
}


#pragma mark - Button actions

- (IBAction)signInButtonTapped:(id)sender
{
    [[HPPRQzoneLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
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



#pragma mark - HPPRSelectPhotoCollectionViewControllerDelegate

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didSelectImage:(UIImage *)image source:(NSString *)source media:(HPPRMedia *)media
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.selectedPhoto = image;
    previewViewController.source = source;
    
//    HPPRQzonePhotoProvider *provider = [HPPRQzonePhotoProvider sharedInstance];
//    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:kCameraRollUserName userId:kCameraRollUserId];
    
    [self presentViewController:previewViewController animated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
}

- (UIEdgeInsets)collectionViewContentInset {
    return UIEdgeInsetsMake(0, 0, PGLandingPageViewControllerCollectionViewBottomInset, 0);
}



@end
