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

#import <MP.h>
#import <MPBTPrintManager.h>
#import <MessageUI/MessageUI.h>

#import "PGSideBarMenuViewController.h"

#import "PGAppAppearance.h"
#import "PGAnalyticsManager.h"
#import "PGBatteryImageView.h"
#import "PGHelpAndHowToViewController.h"
#import "PGRevealViewController.h"
#import "PGSideBarMenuTableViewCell.h"
#import "PGSocialSourcesManager.h"
#import "PGSocialSourcesMenuViewController.h"
#import "PGSurveyManager.h"
#import "PGWebViewerViewController.h"

#import "NSLocale+Additions.h"
#import "UIViewController+Trackable.h"

static NSString *PGSideBarMenuCellIdentifier = @"PGSideBarMenuCell";

CGFloat const kPGSideBarMenuLongScreenSizeHeaderHeight = 75.0f;
CGFloat const kPGSideBarMenuShortScreenSizeHeaderHeight = 52.0f;

@interface PGSideBarMenuViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, PGWebViewerViewControllerDelegate, MPSprocketDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainMenuTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (weak, nonatomic) IBOutlet UIView *deviceStatusLED;
@property (weak, nonatomic) IBOutlet UILabel *deviceConnectivityLabel;
@property (weak, nonatomic) IBOutlet PGBatteryImageView *deviceBatteryLevel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *collapseButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collapseButtonHeightConstraint;

@end

@implementation PGSideBarMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trackableScreenName = @"Side Bar Menu Screen";
    
    [PGAppAppearance addGradientBackgroundToView:self.view];
    
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        self.headerHeight.constant = kPGSideBarMenuShortScreenSizeHeaderHeight;
    }
    
    self.overlayView.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self unselectMenuTableViewCell];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unselectMenuTableViewCell)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [self checkSprocketDeviceConnectivity];
    [self checkPrintQueue];
    [self resizeViewAccordingRevealViewController];
    [self configureSocialSourcesMenu];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.overlayView.alpha != 0) {
        [self toggleSocialSourcesMenu];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDatasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGSideBarMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PGSideBarMenuCellIdentifier];
    [cell configureCellAtIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kPGSideBarMenuItemsNumberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PGSideBarMenuTableViewCell heightForRowAtIndexPath:indexPath];
}


#pragma mark - Print Queue

- (void)showPrintQueueAlert {
    [self.revealViewController revealToggle:self];

    MPBTPrinterManagerStatus status = [MPBTPrintManager sharedInstance].status;

    if (status != MPBTPrinterManagerStatusEmptyQueue) {
        if ([[MP sharedInstance] numberOfPairedSprockets] == 0) {
            [self showPrintQueueAlertNotConnected];
        } else {
            if (status == MPBTPrinterManagerStatusIdle) {
                [self showPrintQueueAlertPaused];
            } else {
                [self showPrintQueueAlertActive];
            }
        }
    } else {
        [self showPrintQueueAlertEmpty];
    }
}

- (NSString *)titleWithNumberOfPrints {
    NSString *format;
    if ([MPBTPrintManager sharedInstance].queueSize == 1) {
        format = NSLocalizedString(@"%li print in Print Queue", @"Message presented when there is only one image in the print queue");
    } else {
        format = NSLocalizedString(@"%li prints in Print Queue", @"Message presented when there more than one images in the print queue");
    }

    return [NSString stringWithFormat:format, [MPBTPrintManager sharedInstance].queueSize];
}

- (void)deletePrintQueue {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete all prints from Print Queue?", nil)
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [[MPBTPrintManager sharedInstance] cancelPrintQueue];
                                                     }];
    [alertController addAction:yesAction];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No, Keep Them", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:noAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPrintQueueAlertNotConnected {
    NSString *title = [NSString stringWithFormat:@"%@,\n%@", [self titleWithNumberOfPrints], NSLocalizedString(@"Sprocket not Connected", nil)];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:NSLocalizedString(@"Photos will print in the order they were added to the Print Queue, after the sprocket printer is on and Bluetooth is connected.", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alertController addAction:okAction];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete All", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self deletePrintQueue];
                                                     }];
    [alertController addAction:deleteAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPrintQueueAlertEmpty {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No prints in Print Queue", @"Message title for when the print queue is empty")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPrintQueueAlertPaused {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self titleWithNumberOfPrints]
                                                                             message:NSLocalizedString(@"Photos will print in the order they were added to the Print Queue.", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alertController addAction:okAction];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete All", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self deletePrintQueue];
                                                         }];
    [alertController addAction:deleteAction];

    UIAlertAction *printAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Print", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [[MPBTPrintManager sharedInstance] resumePrintQueue:nil];
                                                         }];
    [alertController addAction:printAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPrintQueueAlertActive {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self titleWithNumberOfPrints]
                                                                             message:NSLocalizedString(@"Photos will print in the order they were added to the Print Queue.", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alertController addAction:okAction];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete All", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self deletePrintQueue];
                                                         }];
    [alertController addAction:deleteAction];

    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case PGSideBarMenuCellSprocket: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PGSprocketLandingPageNavigationController"];
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case PGSideBarMenuCellPrintQueue: {
            [self showPrintQueueAlert];
            break;
        }
        case PGSideBarMenuCellBuyPaper:{
            [[PGAnalyticsManager sharedManager] trackScreenViewEvent:kBuyPaperScreenName];
            [[UIApplication sharedApplication] openURL:[NSLocale buyPaperURL]];
            break;
        }
        case PGSideBarMenuCellHowToAndHelp: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PrintInstructions"];
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case PGSideBarMenuCellTakeSurvey: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
            UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewerNavigationController"];

            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

            PGWebViewerViewController *webViewerViewController = (PGWebViewerViewController *)navigationController.topViewController;
            webViewerViewController.trackableScreenName = @"Take Our Survey Screen";
            webViewerViewController.url = kSurveyURL;
            webViewerViewController.notifyUrl = kSurveyNotifyURL;
            webViewerViewController.delegate = self;
            [self presentViewController:navigationController animated:YES completion:nil];
            break;
        }
        case PGSideBarMenuCellPrivacy: {
            [[PGAnalyticsManager sharedManager] trackScreenViewEvent:kPrivacyStatementScreenName];
            [[UIApplication sharedApplication] openURL:[NSLocale privacyURL]];
            break;
        }
        case PGSideBarMenuCellAbout: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PGAboutViewController"];
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - MPSprocketDelegate

- (void)didReceiveSprocketBatteryLevel:(NSUInteger)batteryLevel
{
    self.deviceBatteryLevel.level = batteryLevel;
}

#pragma mark - PGWebViewerViewControllerDelegate methods

- (void)webViewerViewControllerDidReachNotifyUrl:(PGWebViewerViewController *)webViewerViewController
{
    [[PGSurveyManager sharedInstance] setDisable:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [webViewerViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewerViewControllerDidDismiss:(PGWebViewerViewController *)webViewerViewController
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - Private Methods

- (void)unselectMenuTableViewCell
{
    [self.mainMenuTableView deselectRowAtIndexPath:[self.mainMenuTableView indexPathForSelectedRow] animated:YES];
}

- (void)checkSprocketDeviceConnectivity {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
        BOOL shouldHideConnectivity = (numberOfPairedSprockets <= 0);
        
        self.deviceConnectivityLabel.hidden = shouldHideConnectivity;
        self.deviceStatusLED.hidden = shouldHideConnectivity;
        self.deviceBatteryLevel.hidden = (1 != numberOfPairedSprockets);
        
        [[MP sharedInstance] checkSprocketForUpdates:self];
    });
}

- (void)checkPrintQueue {
    PGSideBarMenuTableViewCell *cell = [self.mainMenuTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:PGSideBarMenuCellPrintQueue inSection:0]];
    
    cell.menuImageView.image = [cell printQueueImageForQueueSize:[MPBTPrintManager sharedInstance].queueSize];
}

- (void)resizeViewAccordingRevealViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Resizing the table to the width revealed by the SWRevealViewController forces word-wrapping where necessary
        CGRect frame = self.view.frame;
        frame.size.width = self.revealViewController.rearViewRevealWidth;
        self.view.frame = frame;
    });
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)barButtonCancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Social Sources Menu Methods

- (IBAction)overlayViewTapped:(id)sender {
    [self toggleSocialSourcesMenu];
}

- (IBAction)collapseButtonTapped:(id)sender
{
    [self toggleSocialSourcesMenu];
}

- (void)toggleSocialSourcesMenu
{
    [self.view layoutIfNeeded];
    
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI);
    CGFloat overlayAlpha = 0;
    
    if (self.overlayView.alpha != 0) {
        rotationTransform = CGAffineTransformMakeRotation(-(M_PI * 2));
        
        self.overlayView.userInteractionEnabled = NO;
        self.containerHeightConstraint.constant = [self closedSocialSourcesMenuHeightConstraint];
    } else {
        overlayAlpha = 0.7;
        
        self.overlayView.userInteractionEnabled = YES;
        self.containerHeightConstraint.constant = [self openedSocialSourcesMenuHeightConstraint];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.overlayView.alpha = overlayAlpha;
    }];
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.collapseButton.imageView.transform = rotationTransform;
                     } completion:nil];
}

- (void)configureSocialSourcesMenu
{
    if ([self isSocialSourcesDefault]) {
        self.collapseButton.hidden = YES;
        self.containerHeightConstraint.constant = [self openedSocialSourcesMenuHeightConstraint];
    } else {
        self.collapseButton.hidden = NO;
        self.collapseButtonHeightConstraint.constant = [PGSocialSourcesMenuViewController socialSourceCellHeight];
        
        if (self.overlayView.alpha != 0) {
            self.containerHeightConstraint.constant = [self openedSocialSourcesMenuHeightConstraint];
        } else {
            self.containerHeightConstraint.constant = [self closedSocialSourcesMenuHeightConstraint];
        }
    }
}

- (CGFloat)openedSocialSourcesMenuHeightConstraint
{
    NSInteger socialSourcesCount = [PGSocialSourcesManager sharedInstance].enabledSocialSources.count;
    if (![self isSocialSourcesDefault]) {
        socialSourcesCount++;
    }

    return [PGSocialSourcesMenuViewController socialSourceCellHeight] * socialSourcesCount;
}

- (CGFloat)closedSocialSourcesMenuHeightConstraint
{
    NSInteger socialSourcesCount = [PGSocialSourcesManager sharedInstance].enabledSocialSources.count;

    if (![self isSocialSourcesDefault]) {
        socialSourcesCount = kPGSocialSourcesMenuDefaultThreshold;
    }
    
    return [PGSocialSourcesMenuViewController socialSourceCellHeight] * socialSourcesCount;
}

- (BOOL)isSocialSourcesDefault
{
    return [PGSocialSourcesManager sharedInstance].enabledSocialSources.count <= kPGSocialSourcesMenuDefaultThreshold;
}

@end
