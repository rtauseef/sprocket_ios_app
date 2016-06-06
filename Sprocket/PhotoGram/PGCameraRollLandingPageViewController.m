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
#import "PGCameraRollLandingPageViewController.h"
#import "UIViewController+Trackable.h"
#import "PGSelectTemplateViewController.h"
#import "PGImagePickerLandscapeSupportController.h"
#import "PGAnalyticsManager.h"
#import "HPPRCameraRollLoginProvider.h"
#import "HPPRCameraRollPhotoProvider.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Animations.h"
#import "HPPRSelectAlbumTableViewController.h"
#import "SWRevealViewController.h"

NSString * const kCameraRollUserName = @"CameraRollUserName";
NSString * const kCameraRollUserId = @"CameraRollUserId";

@interface PGCameraRollLandingPageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate>

@property (strong, nonatomic) void(^accessCompletion)(BOOL granted);
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (strong, nonatomic) UIImage *selectedPhoto;

@end

@implementation PGCameraRollLandingPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Camera Roll Landing Page Screen";
    
    UIImage *buttonImage = [[UIImage imageNamed:@"DefaultButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 4.0f)];
    [self.signInButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [self setLinkForLabel:self.termsLabel range:[self.termsLabel.text rangeOfString:NSLocalizedString(@"Terms of Service", @"Phrase to make link for terms of service of the landing page") options:NSCaseInsensitiveSearch]];
    
    [self checkCameraRoll];
}

- (IBAction)signInButtonTapped:(id)sender
{
    [[HPPRCameraRollLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self checkCameraRoll];
        }
    }];
}

- (void)checkCameraRoll
{
    UIActivityIndicatorView *spinner = [self.view addSpinner];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    [[HPPRCameraRollLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
            
            HPPRSelectAlbumTableViewController *vc = (HPPRSelectAlbumTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectAlbumTableViewController"];
            
            UIBarButtonItem *hamburgerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStyleBordered target:self.revealViewController action:@selector(revealToggle:)];
            
            vc.navigationItem.leftBarButtonItem = hamburgerButtonItem;
            
            vc.delegate = self;
            
            HPPRCameraRollPhotoProvider *provider = [HPPRCameraRollPhotoProvider sharedInstance];
            vc.provider = provider;
            
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
    PGSelectTemplateViewController *vc = (PGSelectTemplateViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGSelectTemplateViewController"];
    
    HPPRCameraRollPhotoProvider *provider = [HPPRCameraRollPhotoProvider sharedInstance];
    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:kCameraRollUserName userId:kCameraRollUserId];
    
    vc.source = source;
    vc.selectedPhoto = image;
    vc.media = media;
    
    [self.navigationController pushViewController:vc animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
}

@end
