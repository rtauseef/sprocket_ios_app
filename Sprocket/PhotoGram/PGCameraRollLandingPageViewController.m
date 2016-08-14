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
#import "PGSelectTemplateViewController.h"
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
            }
            
            UIBarButtonItem *hamburgerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStyleBordered target:self.revealViewController action:@selector(revealToggle:)];
            
            vc.navigationItem.leftBarButtonItem = hamburgerButtonItem;
            
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SelectTemplateSegue"]) {
        PGSelectTemplateViewController *vc = (PGSelectTemplateViewController *)segue.destinationViewController;

        vc.source = [HPPRCameraRollPhotoProvider sharedInstance].name;

        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:vc
                                                                action:@selector(dismissViewController)];
        [vc.navigationItem setLeftBarButtonItem:item animated:YES];
        
        vc.selectedPhoto = self.selectedPhoto;
    }
}


#pragma mark - HPPRSelectPhotoCollectionViewControllerDelegate

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didSelectImage:(UIImage *)image source:(NSString *)source media:(HPPRMedia *)media
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.selectedPhoto = image;
    previewViewController.source = source;
    previewViewController.media = media;
    
    HPPRCameraRollPhotoProvider *provider = [HPPRCameraRollPhotoProvider sharedInstance];
    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:kCameraRollUserName userId:kCameraRollUserId];
    
    [self presentViewController:previewViewController animated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
}

- (UIEdgeInsets)collectionViewContentInset {
    return UIEdgeInsetsMake(0, 0, PGLandingPageViewControllerCollectionViewBottomInset, 0);
}

@end
