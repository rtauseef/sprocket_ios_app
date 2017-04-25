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

#import "PGPreviewViewController.h"
#import "PGSaveToCameraRollActivity.h"
#import "PGAnalyticsManager.h"
#import "PGCameraManager.h"
#import "PGGesturesView+Analytics.h"
#import "PGAppAppearance.h"
#import "UIView+Background.h"
#import "UIColor+Style.h"
#import "UIFont+Style.h"
#import "PGImglyManager.h"
#import "MPPrintManager.h"
#import "UIViewController+Trackable.h"
#import "PGInterstitialAwarenessViewController.h"
#import "iCarousel.h"
#import "PGPhotoSelection.h"
#import "HPPRCacheService.h"
#import "PGSavePhotos.h"
#import "PGProgressView.h"
#import "PGPreviewDrawerViewController.h"
#import "PGWatermarkProcessor.h"
#import "PGLinkSettings.h"

#import <MP.h>
#import <HPPR.h>
#import <HPPRSelectPhotoProvider.h>
#import <MPLayoutFactory.h>
#import <MPLayout.h>
#import <MPPrintActivity.h>
#import <MPPrintItemFactory.h>
#import <MPBTPrintActivity.h>
#import <MPBTPrintManager.h>
#import <HPPRCameraRollLoginProvider.h>
#import <QuartzCore/QuartzCore.h>
#import <Crashlytics/Crashlytics.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking.h>

#define kPreviewScreenshotErrorTitle NSLocalizedString(@"Oops!", nil)
#define kPreviewScreenshotErrorMessage NSLocalizedString(@"An error occurred when sharing the item.", nil)
#define kPreviewRetryButtonTitle NSLocalizedString(@"Retry", nil)

static NSInteger const screenshotErrorAlertViewTag = 100;
static NSUInteger const kPGPreviewViewControllerPrinterConnectivityCheckInterval = 1;
static NSUInteger const kPGPreviewViewControllerImageViewNegativeMargin = 40;
static NSString * const kPGPreviewViewControllerNumPrintsKey = @"kPGPreviewViewControllerNumPrintsKey";
static CGFloat const kPGPreviewViewControllerCarouselPhotoSizeMultiplier = 1.8;
static NSInteger const kNumPrintsBeforeInterstitialMessage = 2;
static CGFloat kAspectRatio2by3 = 0.66666666667;

@interface PGPreviewViewController() <UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, PGGesturesViewDelegate, PGPreviewDrawerViewControllerDelegate, IMGLYPhotoEditViewControllerDelegate>

@property (strong, nonatomic) MPPrintItem *printItem;
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) PGImglyManager *imglyManager;
@property (strong, nonatomic) NSTimer *sprocketConnectivityTimer;

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *printButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet PGPreviewDrawerViewController *drawer;
@property (weak, nonatomic) IBOutlet UIView *drawerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) IBOutlet iCarousel *carouselView;

@property (strong, nonatomic) PGGesturesView *imageView;
@property (strong, nonatomic) UIPopoverController *popover;
@property (assign, nonatomic) BOOL didChangeProject;
@property (weak, nonatomic) IBOutlet UIView *imageSavedView;
@property (strong, nonatomic) NSString *currentOfframp;
@property (assign, nonatomic) CGPoint panStartPoint;

@property (nonatomic, strong) NSMutableArray<PGGesturesView *> *gesturesViews;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSelectedPhotos;

@property (strong, nonatomic) PGProgressView *progressView;

@end

@implementation PGPreviewViewController

+ (void)presentPreviewPhotoFrom:(UIViewController *)currentViewController andSource:(NSString *)source animated:(BOOL)animated
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.source = source;

    [currentViewController presentViewController:previewViewController animated:animated completion:nil];
}

+ (void)presentCameraFrom:(UIViewController *)currentViewController animated:(BOOL)animated
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.source = [PGPreviewViewController cameraSource];
    
    [currentViewController presentViewController:previewViewController animated:animated completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.trackableScreenName = @"Preview Screen";

    self.didChangeProject = NO;
    
    self.editButton.titleLabel.font = [UIFont HPSimplifiedLightFontWithSize:20];
    self.editButton.titleLabel.tintColor = [UIColor whiteColor];

    self.editButton.hidden = !IS_OS_9_OR_LATER;

    self.imglyManager = [[PGImglyManager alloc] init];

    if ([PGPhotoSelection sharedInstance].hasMultiplePhotos) {
        self.containerViewHeightConstraint.constant = kPGPreviewViewControllerImageViewNegativeMargin;
        self.drawerContainer.userInteractionEnabled = NO;
        self.drawerContainer.hidden = YES;
        
        self.bottomViewHeight.constant *= kPGPreviewViewControllerCarouselPhotoSizeMultiplier;
    } else {
        [[PGAnalyticsManager sharedManager] trackSelectPhoto:self.source];
    }
    
    [self.view layoutIfNeeded];
    
    [self configureCarousel];
    
    [self.view layoutIfNeeded];
    
    [PGAnalyticsManager sharedManager].photoSource = self.source;

    [PGAppAppearance addGradientBackgroundToView:self.previewView];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        
        if (status != AFNetworkReachabilityStatusNotReachable) {
            for (int i = 0; i < self.gesturesViews.count; i++) {
                if (!self.gesturesViews[i].image) {
                    [self loadImageByGestureViewIndex:i];
                }
            }
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view layoutIfNeeded];
    [super viewWillAppear:animated];
    
    if (![PGPhotoSelection sharedInstance].selectedMedia.count) {
        __weak PGPreviewViewController *weakSelf = self;
        [[PGCameraManager sharedInstance] checkCameraPermission:^{
            [[PGCameraManager sharedInstance] addCameraToView:weakSelf.cameraView presentedViewController:self];
            [[PGCameraManager sharedInstance] addCameraButtonsOnView:weakSelf.cameraView];
            [PGCameraManager sharedInstance].isBackgroundCamera = NO;
            [weakSelf showCamera];
        } andFailure:^{
            [[PGCameraManager sharedInstance] showCameraPermissionFailedAlert];
        }];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePreviewAndCamera) name:kPGCameraManagerCameraClosed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoTaken) name:kPGCameraManagerPhotoTaken object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintJobCompletedNotification:) name:kMPBTPrintJobCompletedNotification object:nil];
    
    [self checkSprocketPrinterConnectivity:nil];
    
    self.sprocketConnectivityTimer = [NSTimer scheduledTimerWithTimeInterval:kPGPreviewViewControllerPrinterConnectivityCheckInterval target:self selector:@selector(checkSprocketPrinterConnectivity:) userInfo:nil repeats:YES];
    
    self.numberOfSelectedPhotos.hidden = ![PGPhotoSelection sharedInstance].hasMultiplePhotos;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // hidding imageSavedView on the storyboard to avoid seeing the bar when opening preview screen.
    self.imageSavedView.hidden = NO;
    
    [self.carouselView reloadData];
    
    // Updating visible edited images with the correct contentMode after loading the screen;
    for (PGGesturesView *visibleGestureView in self.carouselView.visibleItemViews) {
        visibleGestureView.editedImage = [visibleGestureView screenshotImage];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.imageSavedView.hidden = YES;
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ENABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[PGCameraManager sharedInstance] stopCamera];
    
    [self.sprocketConnectivityTimer invalidate];
    self.sprocketConnectivityTimer = nil;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    // This prevents our share activities from rotating.
    //  Without this, the share activities rotate, and we rotate (very badly) behind them.
    return UIInterfaceOrientationMaskPortrait;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PGPreviewDrawerViewController"]){
        self.drawer = (PGPreviewDrawerViewController *)segue.destinationViewController;
        self.drawer.delegate = self;
    }
}

#pragma mark - Internal Methods

- (void)checkSprocketPrinterConnectivity:(NSTimer *)timer
{
    NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
    
    if (numberOfPairedSprockets > 0) {
        [self.printButton setImage:[UIImage imageNamed:@"previewPrinterActive"] forState:UIControlStateNormal];
    } else {
        [self.printButton setImage:[UIImage imageNamed:@"previewPrinterInactive"] forState:UIControlStateNormal];
    }
}

- (void)showImgly
{
    UIImage *photoToEdit = nil;
    
    PGGesturesView *gesturesView = self.gesturesViews[self.carouselView.currentItemIndex];
    photoToEdit = [self currentEditedImage];
    
    IMGLYConfiguration *configuration = [self.imglyManager imglyConfigurationWithEmbellishmentManager:gesturesView.embellishmentMetricManager];

    NSArray<IMGLYBoxedMenuItem *> *menuItems = [self.imglyManager menuItemsWithConfiguration:configuration];

    IMGLYPhotoEditViewController *photoController = [[IMGLYPhotoEditViewController alloc] initWithPhoto:photoToEdit menuItems:menuItems configuration:configuration];
//    IMGLYPhotoEditViewController *photoController = [[IMGLYPhotoEditViewController alloc] initWithPhoto:photoToEdit configuration:configuration];

    photoController.delegate = self;

    IMGLYToolbarController *toolController = [[IMGLYToolbarController alloc] init];
    toolController.toolbar.backgroundColor = [UIColor HPRowColor];

    [toolController pushViewController:photoController animated:NO completion:nil];
    [toolController setModalPresentationStyle:UIModalPresentationOverFullScreen];
    [toolController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self presentViewController:toolController animated:YES completion:^() {
        NSString *screenName = @"Editor Screen";
        [[PGAnalyticsManager sharedManager] trackScreenViewEvent:screenName];
        [[Crashlytics sharedInstance] setObjectValue:screenName forKey:[UIViewController screenNameKey]];
    }];
}

- (void)hideSavedImageView:(NSObject *)dummy
{
    [self showImageSavedView:NO];
}

- (void)showImageSavedView:(BOOL)show
{
    CGRect frame = self.topView.frame;
    if (!show) {
        frame.origin.y -= frame.size.height;
    }
    
    [UIView animateWithDuration:0.5F animations:^{
        self.imageSavedView.frame = frame;
    }];
}

- (void)savePhoto:(NSArray *)images index:(NSInteger)index withCompletion:(void (^)(BOOL))completion
{
    __block NSArray *savedImages = images;
    __block NSInteger idx = index;

    UIImage *image = [savedImages objectAtIndex:idx++];

    if (image) {
        [PGSavePhotos saveImage:image completion:^(BOOL success) {
            if (success && [savedImages count] > idx) {
                [self savePhoto:savedImages index:idx withCompletion:completion];
            } else if (completion) {
                completion(success);
            }
        }];

    } else if (completion) {
        completion(NO);
    }
}

- (void)saveSelectedPhotosWithCompletion:(void (^)(BOOL))completion
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (PGGesturesView *gestureView in self.gesturesViews) {
        if (gestureView.isSelected && gestureView.editedImage) {
            [images addObject:gestureView.editedImage];
        }
    }

    if (images.count > 0) {
        [self savePhoto:images index:0 withCompletion:completion];
    }
}

- (void)reloadCarouselItems
{
    [self.view layoutIfNeeded];
    [self.carouselView reloadData];
}

- (BOOL)hasImageSelected
{
    for (PGGesturesView *gestureView in self.gesturesViews) {
        if (gestureView.isSelected) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)hasPendingImagesDownload
{
    for (PGGesturesView *gestureView in self.gesturesViews) {
        if (gestureView.isDownloading) {
            return YES;
        }
    }
    
    return NO;
}

- (void)configureActionButtons
{
    BOOL hasImageSelected = [self hasImageSelected];
    
    self.downloadButton.enabled = hasImageSelected;
    self.printButton.enabled = hasImageSelected;
    self.shareButton.enabled = hasImageSelected;
}

- (void)showDownloadingImagesAlertWithCompletion:(void (^)())completion
{
    if ([self hasPendingImagesDownload]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Not all images were downloaded. Do you want to continue?", nil)
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            completion();
        }];
        
        [alert addAction:okAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        completion();
    }
}

#pragma mark - Drawer Methods

- (void)closeDrawer
{
    if (!self.drawer.isOpened) {
        return;
    }
    
    self.drawer.isOpened = NO;
    self.containerViewHeightConstraint.constant = [self.drawer drawerHeight];
    [self reloadCarouselItems];
}

- (void)openDrawer
{
    if (self.drawer.isOpened) {
        return;
    }
    
    self.drawer.isOpened = YES;
    self.containerViewHeightConstraint.constant = [self.drawer drawerHeight];
    [self reloadCarouselItems];
}

#pragma mark - PGPreviewDrawerDelegate

- (void)PGPreviewDrawer:(PGPreviewDrawerViewController *)drawer didTapButton:(UIButton *)button
{
    self.containerViewHeightConstraint.constant = [drawer drawerHeight];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self reloadCarouselItems];
    }];
}

- (void)PGPreviewDrawer:(PGPreviewDrawerViewController *)drawer didDrag:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:self.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat newHeight = [drawer drawerHeight] - translation.y;
        
        BOOL isTopLimit = newHeight > [drawer drawerHeightOpened];
        BOOL isBottomLimit = newHeight < [drawer drawerHeightClosed];
        if (!isTopLimit && !isBottomLimit) {
            self.containerViewHeightConstraint.constant = newHeight;
            [self reloadCarouselItems];
        }
        
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGFloat threshold = [drawer drawerHeightOpened] * 0.7;
        if (!drawer.isOpened) {
            threshold = [drawer drawerHeightOpened] * 0.3;
        }
        
        drawer.isOpened = self.containerViewHeightConstraint.constant > threshold;
        self.containerViewHeightConstraint.constant = [drawer drawerHeight];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self reloadCarouselItems];
        }];
    }
}


#pragma mark - IMGLYPhotoEditViewControllerDelegate

- (void)photoEditViewController:(IMGLYPhotoEditViewController *)photoEditViewController didSaveImage:(UIImage *)image imageAsData:(NSData *)data {
    PGGesturesView *currentGesturesView = self.gesturesViews[self.carouselView.currentItemIndex];
    [currentGesturesView setImage:image];

    currentGesturesView.scrollView.transform = CGAffineTransformIdentity;
    currentGesturesView.totalRotation = 0.0F;
    currentGesturesView.scrollView.zoomScale = currentGesturesView.minimumZoomScale;

    [self dismissViewControllerAnimated:YES completion:nil];

    self.didChangeProject = YES;
    [self.carouselView reloadItemAtIndex:self.carouselView.currentItemIndex animated:YES];

    [self currentEditedImage];
}

- (void)photoEditViewControllerDidCancel:(IMGLYPhotoEditViewController *)photoEditViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditViewControllerDidFailToGeneratePhoto:(IMGLYPhotoEditViewController *)photoEditViewController {
    MPLogError(@"photoEditViewControllerDidFailToGeneratePhoto:%@", photoEditViewController);
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Camera Handlers

- (void)closePreviewAndCamera {
    if (![PGPhotoSelection sharedInstance].isInSelectionMode) {
        [[PGPhotoSelection sharedInstance] endSelectionMode];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPGCameraManagerCameraClosed object:nil];
    }];
}

- (void)hideCamera {
    self.previewView.alpha = 1;
}

- (void)showCamera {    
    self.previewView.alpha = 0;
    [PGCameraManager logMetrics];
}

- (void)photoTaken {
    [self hideCamera];
    
    self.didChangeProject = NO;
    self.source = [PGPreviewViewController cameraSource];
    PGGesturesView *gesturesView = [self createGestureViewWithMedia:[PGPhotoSelection sharedInstance].selectedMedia[0]];
    self.gesturesViews = [NSMutableArray arrayWithObject:gesturesView];
    
    [PGAnalyticsManager sharedManager].photoSource = self.source;
    [self.carouselView reloadData];
}

+ (NSString *)cameraSource
{
    return @"Camera";
}

#pragma mark - PGGesture Delegate

- (void)imageEdited:(PGGesturesView *)gesturesView {
    self.didChangeProject = YES;
}

- (void)handleLongPress:(PGGesturesView *)gesturesView {
    
}


#pragma mark - Bottom Menu Handlers

- (IBAction)didTouchUpInsideDownloadButton:(id)sender
{
    [self showDownloadingImagesAlertWithCompletion:^{
        [self closeDrawer];
        [self saveSelectedPhotosWithCompletion:^(BOOL success) {
            if (success) {
                if (![PGPhotoSelection sharedInstance].isInSelectionMode) {
                    [[PGAnalyticsManager sharedManager] trackSaveProjectActivity:kEventSaveProjectPreview];
                    
                    [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:NSStringFromClass([PGSaveToCameraRollActivity class])
                                                                     printItem:self.printItem
                                                                  extendedInfo:[self extendedMetricsByGestureView:(PGGesturesView *)self.carouselView.currentItemView]];
                } else {
                    NSUInteger selectedPhotosCount = 0;
                    
                    // Print Metric
                    NSString *offRampMetric = [NSString stringWithFormat:@"%@-Multi", NSStringFromClass([PGSaveToCameraRollActivity class])];
                    for (PGGesturesView *gestureView in self.gesturesViews) {
                        if (gestureView.isSelected) {
                            MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:gestureView.editedImage];
                            printItem.layout = [self layout];
                            
                            [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offRampMetric
                                                                             printItem:printItem
                                                                          extendedInfo:[self extendedMetricsByGestureView:gestureView]];
                            selectedPhotosCount++;
                        }
                    }
                    
                    // Analytics Metric
                    [[PGAnalyticsManager sharedManager] trackMultiSaveProjectActivity:[NSString stringWithFormat:@"%@-Multi", kEventSaveProjectPreview] numberOfPhotos:selectedPhotosCount];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.5F animations:^{
                        [self showImageSavedView:YES];
                    } completion:^(BOOL finished) {
                        [self performSelector:@selector(hideSavedImageView:) withObject:nil afterDelay:1.0];
                    }];
                });
            }
        }];
    }];
}

- (IBAction)didTouchUpInsideCloseButton:(id)sender
{
    if (self.didChangeProject) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Save and exit preview?", nil)
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[PGAnalyticsManager sharedManager] trackDismissEditActivity:kEventDismissEditCancelAction
                                                                  source:kEventDismissEditCloseLabel];
        }];
        [alert addAction:cancelAction];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Don't Save", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self closePreviewAndCamera];
            [[PGAnalyticsManager sharedManager] trackDismissEditActivity:kEventDismissEditOkAction
                                                                  source:kEventDismissEditCloseLabel];
        }];
        [alert addAction:okAction];

        __weak PGPreviewViewController *weakSelf = self;
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

            [self saveSelectedPhotosWithCompletion:^(BOOL success) {
                if (success) {
                    if (![PGPhotoSelection sharedInstance].isInSelectionMode) {
                        [[PGAnalyticsManager sharedManager] trackDismissEditActivity:kEventDismissEditSaveAction
                                                                              source:kEventDismissEditCloseLabel];
                        
                        [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:NSStringFromClass([PGSaveToCameraRollActivity class])
                                                                         printItem:weakSelf.printItem
                                                                       extendedInfo:[weakSelf extendedMetricsByGestureView:(PGGesturesView *)weakSelf.carouselView.currentItemView]];
                    } else {
                        NSUInteger selectedPhotosCount = 0;
                        
                        // Print Metric
                        NSString *offRampMetric = [NSString stringWithFormat:@"%@-Multi", NSStringFromClass([PGSaveToCameraRollActivity class])];
                        for (PGGesturesView *gestureView in self.gesturesViews) {
                            if (gestureView.isSelected) {
                                MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:gestureView.editedImage];
                                printItem.layout = [self layout];
                                
                                [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offRampMetric
                                                                                 printItem:printItem
                                                                               extendedInfo:[weakSelf extendedMetricsByGestureView:gestureView]];
                                selectedPhotosCount++;
                            }
                        }
                        
                        // Analytics Metric
                        [[PGAnalyticsManager sharedManager] trackMultiSaveProjectActivity:[NSString stringWithFormat:@"%@-Multi", kEventSaveProjectDismiss] numberOfPhotos:selectedPhotosCount];
                    }
                    
                    [self closePreviewAndCamera];
                }
            }];
        }];
        [alert addAction:saveAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self closePreviewAndCamera];
    }
}

- (IBAction)didTouchUpInsideEditButton:(id)sender
{
    BOOL drawerWasOpened = self.drawer.isOpened;
    [self closeDrawer];
    [self showImgly];
    
    if (drawerWasOpened) {
        [self openDrawer];
    }
}

- (IBAction)didTouchUpInsidePrinterButton:(id)sender
{
    [self showDownloadingImagesAlertWithCompletion:^{
        [self closeDrawer];
        [[MP sharedInstance] presentBluetoothDeviceSelectionFromController:self animated:YES completion:^(BOOL success) {
            if (success) {
                NSString *origin = @"";
                NSMutableArray<PGGesturesView *> *selectedViews = [[NSMutableArray alloc] init];
                for (PGGesturesView *gestureView in self.gesturesViews) {
                    if (gestureView.isSelected) {
                        [selectedViews addObject:gestureView];
                    }
                }

                NSString *offRamp;
                BOOL isPrintDirect = NO;

                if ((selectedViews.count == 1) && (self.drawer.numberOfCopies == 1)) {
                    if ([MPBTPrintManager sharedInstance].status == MPBTPrinterManagerStatusEmptyQueue) {
                        isPrintDirect = YES;
                        offRamp = kMetricsOffRampPrintNoUISingle;
                        origin = kMetricsOriginSingle;
                        
                        if ([[PGPhotoSelection sharedInstance] isInSelectionMode]) {
                            offRamp = kMetricsOffRampPrintNoUIMulti;
                        }
                    } else {
                        origin = kMetricsOriginSingle;
                        offRamp = kMetricsOffRampQueueAddSingle;
                    }
                } else if (selectedViews.count > 1) {
                    origin = kMetricsOriginMulti;
                    offRamp = kMetricsOffRampQueueAddMulti;
                } else if (self.drawer.numberOfCopies > 1) {
                    origin = kMetricsOriginCopies;
                    offRamp = kMetricsOffRampQueueAddCopies;
                    for (NSInteger i = 1; i < self.drawer.numberOfCopies; i++) {
                        [selectedViews addObject:selectedViews.firstObject];
                    }
                }

                __block BOOL canResumePrinting = YES;

                for (PGGesturesView *gestureView in selectedViews) {
                    NSMutableDictionary *extendedMetrics = [[NSMutableDictionary alloc] init];
                    [extendedMetrics addEntriesFromDictionary:[self extendedMetricsByGestureView:gestureView]];

                    void (^block)(UIImage *image) = ^(UIImage *image) {
                        MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:image];
                        NSMutableDictionary *metrics = [[PGAnalyticsManager sharedManager] getMetrics:offRamp printItem:printItem extendedInfo:extendedMetrics];

                        [metrics setObject:origin forKey:kMetricsOrigin];

                        if (isPrintDirect) {
                            [[MPBTPrintManager sharedInstance] printDirect:printItem metrics:metrics statusUpdate:^BOOL(MPBTPrinterManagerStatus status, NSInteger progress) {
                                return [self handlePrintQueueStatus:status progress:progress];
                            }];
                            canResumePrinting = NO;
                        } else {
                            [metrics setObject:@([MPBTPrintManager sharedInstance].queueId) forKey:kMetricsPrintQueueIdKey];
                            [metrics setObject:@(self.drawer.numberOfCopies) forKey:kMetricsPrintQueueCopiesKey];

                            if (![[MPBTPrintManager sharedInstance] addPrintItemToQueue:printItem metrics:metrics]) {
                                canResumePrinting = NO;
                            }

                            [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offRamp
                                                                             printItem:printItem
                                                                          extendedInfo:metrics];
                        }
                    };

                    PGWatermarkProcessor *processor;
                    if ([PGLinkSettings linkEnabled] && gestureView.media && gestureView.media.socialMediaImageUrl) {
                        processor = [[PGWatermarkProcessor alloc] initWithWatermarkURL:[NSURL URLWithString:gestureView.media.socialMediaImageUrl]];
                    }

                    if (processor) {
                        [processor processImage:gestureView.editedImage
                                    withOptions:[[MPBTPrintManager sharedInstance] defaultOptionsForImageProcessor]
                                     completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
                                         if (!error) {
                                             block(image);
                                         } else {
                                             NSLog(@"Error watermarking image: %@", error);
                                             NSLog(@"Proceeding with original image.");
                                             block(gestureView.editedImage);
                                         }
                                     }];
                    } else {
                        block(gestureView.editedImage);
                    }

                    if (!canResumePrinting) {
                        break;
                    }

                }

                if (canResumePrinting) {
                    [[MPBTPrintManager sharedInstance] resumePrintQueue:^(MPBTPrinterManagerStatus status, NSInteger progress) {
                        return [self handlePrintQueueStatus:status progress:progress];
                    }];

                    NSString *action = kEventPrintQueueAddSingleAction;
                    if ([MPBTPrintManager sharedInstance].originalQueueSize > 1) {
                        action = kEventPrintQueueAddMultiAction;
                    }
                    
                    if (self.drawer.numberOfCopies > 1) {
                        action = kEventPrintQueueAddCopiesAction;
                    }

                    [[PGAnalyticsManager sharedManager] trackPrintQueueAction:action
                                                                      queueId:[MPBTPrintManager sharedInstance].queueId
                                                                    queueSize:[MPBTPrintManager sharedInstance].originalQueueSize];
                }
            }
        }];
    }];
}

- (IBAction)didTouchUpInsideShareButton:(id)sender
{
    [self showDownloadingImagesAlertWithCompletion:^{
        [self closeDrawer];
        [[MP sharedInstance] closeAccessorySession];
        
        [self presentActivityViewControllerWithActivities:nil];
    }];
}


#pragma mark - Print preparation

- (BOOL)handlePrintQueueStatus:(MPBTPrinterManagerStatus)status progress:(NSInteger)progress {
    if (status == MPBTPrinterManagerStatusResumingPrintQueue) {
        if (!self.progressView) {
            self.progressView = [[PGProgressView alloc] initWithFrame:self.view.bounds];
            self.progressView.alpha = 0.0;
            [self.progressView setProgress:0.0];

            [self.view addSubview:self.progressView];
            [self.view bringSubviewToFront:self.progressView];

            [UIView animateWithDuration:0.3 animations:^{
                self.progressView.alpha = 1.0;
            }];
        }

        [self.progressView setProgress:0.0];
        [self.progressView setText:NSLocalizedString(@"Sending to sprocket printer", @"Indicates that the phone is sending an image to the printer")];

    } else if (status == MPBTPrinterManagerStatusSendingPrintJob) {
        [self.progressView setProgress:(((CGFloat)progress) / 100.0F) * 0.9F];

    } else if (status == MPBTPrinterManagerStatusPrinting) {
        [self.progressView setProgress:1.0F];
        [self dismissProgressView];

        return NO;

    } else if (status == MPBTPrinterManagerStatusIdle) {
        // User paused the print queue
        [self dismissProgressView];

        return NO;
    }

    return YES;
}

- (void)dismissProgressView {
    [UIView animateWithDuration:0.3 animations:^{
        self.progressView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }];
}

- (MPPaper *)paper
{
    return [MP sharedInstance].defaultPaper;
}

- (MPLayout *)layout
{
    return [MPLayoutFactory layoutWithType:[MPLayoutFill layoutType]];
}

- (NSDictionary *)extendedMetricsByGestureView:(PGGesturesView *)gestureView
{
    [PGAnalyticsManager sharedManager].photoSource = gestureView.media.photoProvider.name;
     
    return @{
             kMetricsTypePhotoSourceKey:[[PGAnalyticsManager sharedManager] photoSourceMetrics],
             kMPMetricsEmbellishmentKey:gestureView.embellishmentMetricManager.embellishmentMetricsString,
             };
}

- (void)presentActivityViewControllerWithActivities:(NSArray *)applicationActivities
{
    if (nil == self.printItem) {
        // NOTE. We couldn't recreate this situation, but there is a crash reported in crashlytics indicating that this has happened: Crash 1.3(995) #81
        if (NSClassFromString(@"UIAlertController") != nil) {
            UIAlertController *errorScreenshotController = [UIAlertController alertControllerWithTitle:kPreviewScreenshotErrorTitle message:kPreviewScreenshotErrorMessage preferredStyle:UIAlertControllerStyleAlert];
            [errorScreenshotController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
            [errorScreenshotController addAction:[UIAlertAction actionWithTitle:kPreviewRetryButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self didTouchUpInsideShareButton:nil];
            }]];
            
            [self presentViewController:errorScreenshotController animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kPreviewScreenshotErrorTitle message:kPreviewScreenshotErrorMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:kPreviewRetryButtonTitle, nil];
            alertView.tag = screenshotErrorAlertViewTag;
            [alertView show];
        }
    } else {        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:[self editedImagesSelected] applicationActivities:applicationActivities];
        
        [activityViewController setValue:NSLocalizedString(@"Check out my HP Sprocket creation", nil) forKey:@"subject"];
        
        activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,
                                                         UIActivityTypeSaveToCameraRoll,
                                                         UIActivityTypePostToWeibo,
                                                         UIActivityTypePostToTencentWeibo,
                                                         UIActivityTypeAddToReadingList,
                                                         UIActivityTypePrint,
                                                         UIActivityTypeAssignToContact,
                                                         UIActivityTypePostToVimeo];
        
        __weak __typeof(self) weakSelf = self;
        activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *items, NSError *error) {
            
            BOOL printActivity = [activityType isEqualToString: NSStringFromClass([MPBTPrintActivity class])];
            
            NSString *offramp = activityType;
            
            if (printActivity) {
                offramp = [MPPrintManager printOfframp];
                [[PGAnalyticsManager sharedManager] trackPrintRequest:kEventPrintShareLabel];
            }
            
            if (!offramp) {
                PGLogError(@"Missing offramp key for share activity");
                offramp = @"Unknown";
            }
            
            if (completed) {
                if (!printActivity) {
                    if (![PGPhotoSelection sharedInstance].isInSelectionMode) {
                        NSDictionary *extendedMetrics = [weakSelf extendedMetricsByGestureView:(PGGesturesView *)[weakSelf.gesturesViews objectAtIndex:weakSelf.carouselView.currentItemIndex]];
                        [[PGAnalyticsManager sharedManager] trackShareActivity:offramp withResult:kEventResultSuccess];
                        [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offramp printItem:weakSelf.printItem extendedInfo:extendedMetrics];
                    } else {
                        NSUInteger selectedPhotosCount = 0;
                        
                        // Print Metric
                        NSString *offRampMetric = [NSString stringWithFormat:@"%@-Multi", offramp];
                        
                        for (PGGesturesView *gestureView in weakSelf.gesturesViews) {
                            if (gestureView.isSelected) {
                                NSDictionary *extendedMetrics = [weakSelf extendedMetricsByGestureView:gestureView];
                                MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:gestureView.editedImage];
                                printItem.layout = [weakSelf layout];
                                
                                [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offRampMetric
                                                                                 printItem:printItem
                                                                               extendedInfo:extendedMetrics];
                                
                                selectedPhotosCount++;
                            }
                        }

                        // GA Metric
                        [[PGAnalyticsManager sharedManager] trackShareActivity:offRampMetric withResult:kEventResultSuccess andNumberOfPhotos:selectedPhotosCount];
                    }
                } else {
                    self.currentOfframp = offramp;
                }
            } else {
                if (activityType) {
                    if (![PGPhotoSelection sharedInstance].isInSelectionMode) {
                        [[PGAnalyticsManager sharedManager] trackShareActivity:offramp withResult:kEventResultCancel];
                    } else {
                        NSUInteger selectedPhotosCount = 0;
                        NSString *offRampMetric = [NSString stringWithFormat:@"%@-Multi", offramp];
                        
                        for (PGGesturesView *gestureView in weakSelf.gesturesViews) {
                            if (gestureView.isSelected) {
                                selectedPhotosCount++;
                            }
                        }
                        [[PGAnalyticsManager sharedManager] trackShareActivity:offRampMetric withResult:kEventResultCancel andNumberOfPhotos:selectedPhotosCount];
                    }
                }
            }
        };
        
        activityViewController.popoverPresentationController.sourceRect = self.shareButton.bounds;
        activityViewController.popoverPresentationController.sourceView = self.shareButton;
        activityViewController.popoverPresentationController.delegate = self;
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

- (void)handlePrintJobCompletedNotification:(NSNotification *)notification
{
    NSString *error = [notification.userInfo objectForKey:kMPBTPrintJobErrorKey];
    
    if (nil == error) {
        NSInteger numPrints = [[NSUserDefaults standardUserDefaults] integerForKey:kPGPreviewViewControllerNumPrintsKey] + 1;

        if (kNumPrintsBeforeInterstitialMessage == numPrints) {
            PGInterstitialAwarenessViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier: @"PGInterstitialAwarenessViewController"];
            vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:vc animated:YES completion:nil];
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:numPrints forKey:kPGPreviewViewControllerNumPrintsKey];
        
        [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:self.currentOfframp printItem:self.printItem extendedInfo:[self extendedMetricsByGestureView:(PGGesturesView *)self.carouselView.currentItemView]];
        
        self.currentOfframp = nil;
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate

// NOTE: The implementation of this delegate with the default value is a workaround to compensate an error in the new popover presentation controller of the SDK 8.
// This fix corrects the case where if the user keep tapping repeatedly the share button in an iPad iOS 8, the app goes back to the first screen.

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}

#pragma mark - Carousel methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (void)selectCarouselItem:(NSInteger)index
{
    if (![PGPhotoSelection sharedInstance].hasMultiplePhotos || !self.gesturesViews[index].image) {
        return;
    }
    
    NSInteger countSelected = 0;
    for (PGGesturesView *gestureView in self.gesturesViews) {
        if (gestureView.isSelected) {
            countSelected++;
        }
    }
    BOOL shouldSelect = !(self.gesturesViews[index].isSelected && (countSelected >= 2));
    self.gesturesViews[index].isSelected = shouldSelect;
    
    [self configureActionButtons];
}

- (void)configureCarousel
{
    self.carouselView.type = iCarouselTypeLinear;
    [self.carouselView setBounceDistance:0.3];
    [self.carouselView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)]];
    [self.carouselView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
    
    if (![PGPhotoSelection sharedInstance].hasMultiplePhotos) {
        self.carouselView.bounces = NO;
    }
    
    self.carouselView.pagingEnabled = YES;
    
    self.gesturesViews = [NSMutableArray array];
    NSArray<HPPRMedia *> *selectedMedia = [PGPhotoSelection sharedInstance].selectedMedia;
    
    __weak typeof(self) weakSelf = self;
    for (int i = 0; i < selectedMedia.count; i++) {
        [self.gesturesViews addObject:[self createGestureViewWithMedia:selectedMedia[i]]];
        
        if ([self.source isEqualToString:[PGPreviewViewController cameraSource]]) {
            [weakSelf.carouselView reloadItemAtIndex:i animated:NO];
            return;
        }
        
        [self loadImageByGestureViewIndex:i];
    }
}

- (void)loadImageByGestureViewIndex:(NSUInteger)index
{
    __weak typeof(self) weakSelf = self;
    if (self.gesturesViews[index].media.asset) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.gesturesViews[index].media requestImageWithCompletion:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.gesturesViews[index] setImage:image];
                    weakSelf.gesturesViews[index].isSelected = YES;
                    [weakSelf.carouselView reloadItemAtIndex:index animated:NO];
                });
            }];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakSelf.gesturesViews[index].isDownloading = YES;
            [weakSelf.view layoutIfNeeded];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.gesturesViews[index] hideNoInternetConnectionView];
            });
            [[HPPRCacheService sharedInstance] imageForUrl:weakSelf.gesturesViews[index].media.standardUrl asThumbnail:NO withCompletion:^(UIImage *image, NSString *url, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.gesturesViews[index] showNoInternetConnectionView];
                        [weakSelf.carouselView reloadItemAtIndex:index animated:NO];
                    });
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.gesturesViews[index] setImage:image];
                    weakSelf.gesturesViews[index].isSelected = YES;
                    weakSelf.gesturesViews[index].isDownloading = NO;
                    [weakSelf.gesturesViews[index] hideNoInternetConnectionView];
                    [weakSelf.carouselView reloadItemAtIndex:index animated:NO];
                });
            }];
        });
    }

}

- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentPoint = [recognizer translationInView:self.carouselView];
    CGFloat deltaX = -((currentPoint.x - self.panStartPoint.x) / self.carouselView.itemWidth);
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = currentPoint;
            break;
        case UIGestureRecognizerStateChanged:
            self.panStartPoint = currentPoint;
            [self.carouselView scrollByOffset:deltaX duration:0];
            break;
        case UIGestureRecognizerStateEnded:
            [self.carouselView scrollToItemAtIndex:round(self.carouselView.currentItemIndex + deltaX) animated:YES];
            break;
        default:
            break;
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    [self selectCarouselItem:self.carouselView.currentItemIndex];
}

- (CGRect)carouselItemFrame
{
    return CGRectMake(0, 0, self.carouselView.bounds.size.height * kAspectRatio2by3, self.carouselView.bounds.size.height);;
}

- (PGGesturesView *)createGestureViewWithMedia:(HPPRMedia *)media
{
    PGGesturesView *gestureView = [[PGGesturesView alloc] initWithFrame:[self carouselItemFrame]];
    gestureView.media = media;
    gestureView.isMultiSelectImage = [PGPhotoSelection sharedInstance].hasMultiplePhotos;
    
    if (media.image) {
        UIImage *finalImage = media.image;
        
        if (media.image.size.width > media.image.size.height) {
            finalImage = [[UIImage alloc] initWithCGImage: media.image.CGImage
                                                    scale: 1.0
                                              orientation: UIImageOrientationRight];
        }
        
        gestureView.image = finalImage;
        
        [self.carouselView setNeedsLayout];
    } else {
        gestureView.isSelected = NO;
    }
    
    return gestureView;
}

- (UIImage *)currentEditedImage
{
    PGGesturesView *gesturesView = self.gesturesViews[self.carouselView.currentItemIndex];
    gesturesView.editedImage = [gesturesView screenshotImage];
    
    return gesturesView.editedImage;
}

- (NSMutableArray<UIImage *> *)editedImagesSelected
{
    NSMutableArray *editedImages = [NSMutableArray array];
    
    for (PGGesturesView *gestureView in self.gesturesViews) {
        if (gestureView.isSelected) {
            [editedImages addObject:gestureView.editedImage];
        }
    }
    
    return editedImages;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.gesturesViews count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    PGGesturesView *gestureView = self.gesturesViews[index];
    gestureView.frame = [self carouselItemFrame];
    
    if (gestureView.image) {
        UIImage *finalImage = gestureView.image;
        
        if (gestureView.image.size.width > gestureView.image.size.height) {
            finalImage = [[UIImage alloc] initWithCGImage: gestureView.image.CGImage
                                                    scale: 1.0
                                              orientation: UIImageOrientationRight];
        }

        [gestureView setImage:finalImage];
        
        BOOL isVisibleItem = [carousel.indexesForVisibleItems containsObject:[NSNumber numberWithInteger:index]];
        if (isVisibleItem) {
            gestureView.editedImage = [gestureView screenshotImage];
        }

        [carousel setNeedsLayout];
    }
    
    self.editButton.hidden = !gestureView.isSelected || !IS_OS_9_OR_LATER;
    
    if (self.printItem == nil && index == 0) {
        self.printItem = [MPPrintItemFactory printItemWithAsset:gestureView.editedImage];
        self.printItem.layout = [self layout];
    }
    
    return gestureView;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [self selectCarouselItem:index];
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    if ([PGPhotoSelection sharedInstance].hasMultiplePhotos && (carousel.currentItemIndex != -1)) {
        self.numberOfSelectedPhotos.text = [NSString stringWithFormat:NSLocalizedString(@"%ld of %ld", nil), (carousel.currentItemIndex + 1), (long)self.gesturesViews.count];
        self.editButton.hidden = !self.gesturesViews[carousel.currentItemIndex].isSelected || !IS_OS_9_OR_LATER;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.printItem = [MPPrintItemFactory printItemWithAsset:[self currentEditedImage]];
            self.printItem.layout = [self layout];
        });
    }
    
    [self configureActionButtons];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    [self.view layoutIfNeeded];
    
    if (option == iCarouselOptionWrap) {
        return self.gesturesViews.count > 2;
    }
    
    return value;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return 10.0f + (self.carouselView.bounds.size.height * kAspectRatio2by3);
}

@end
