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
#import "PGWatermarkProcessor.h"
#import "PGPayoffProcessor.h"
#import "PGProgressView.h"
#import "PGPreviewDrawerViewController.h"
#import "PGPayoffManager.h"
#import "PGLinkSettings.h"
#import "PGPrintQueueManager.h"
#import "PGSetupSprocketViewController.h"
#import "PGTilingOverlay.h"
#import "PGLog.h"
#import "PGPartyGuestManager.h"
#import "PGPrintProcessingInfo.h"

#import <MP.h>
#import <HPPR.h>
#import <HPPRSelectPhotoProvider.h>
#import <MPLayoutFactory.h>
#import <MPLayout.h>
#import <MPPrintActivity.h>
#import <MPPrintItemFactory.h>
#import <MPBTPrintActivity.h>
#import <MPBTPrintManager.h>
#import <MPBTImagePreprocessorManager.h>
#import <HPPRCameraRollLoginProvider.h>
#import <QuartzCore/QuartzCore.h>
#import <Crashlytics/Crashlytics.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking.h>


#define kPreviewScreenshotErrorTitle NSLocalizedString(@"Oops!", nil)
#define kPreviewScreenshotErrorMessage NSLocalizedString(@"An error occurred when sharing the item.", nil)
#define kPreviewRetryButtonTitle NSLocalizedString(@"Retry", nil)

NSString * const kPGPreviewViewClosed = @"PGPreviewViewClosed";

static NSInteger const screenshotErrorAlertViewTag = 100;
static NSUInteger const kPGPreviewViewControllerPrinterConnectivityCheckInterval = 1;
static NSString * const kPGPreviewViewControllerNumPrintsKey = @"kPGPreviewViewControllerNumPrintsKey";
static NSString * const kMPBTPrinterConnected = @"printer_connected";
static CGFloat const kPGPreviewViewControllerCarouselPhotoSizeMultiplier = 1.4;
static CGFloat const kDrawerAnimationDuration = 0.3;
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
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet PGPreviewDrawerViewController *drawer;
@property (assign, nonatomic) BOOL wasDrawerOpenedByUser;
@property (weak, nonatomic) IBOutlet UIView *drawerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) IBOutlet iCarousel *carouselView;

@property (strong, nonatomic) PGGesturesView *imageView;
@property (strong, nonatomic) UIPopoverController *popover;
@property (assign, nonatomic) BOOL didChangeProject;
@property (weak, nonatomic) IBOutlet UIView *imageSavedView;
@property (weak, nonatomic) IBOutlet UILabel *imageSavedLabel;
@property (strong, nonatomic) NSString *currentOfframp;
@property (assign, nonatomic) CGPoint panStartPoint;

@property (nonatomic, strong) NSMutableArray<PGGesturesView *> *gesturesViews;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSelectedPhotos;

@property (strong, nonatomic) PGProgressView *progressView;
@property (strong, nonatomic) IMGLYPhotoEditViewController *photoEditViewController;

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (assign, nonatomic) NSInteger assetNumber;
@property (assign, nonatomic) NSInteger assetCount;
@property (assign, nonatomic) NSInteger addToQueueCount;

@property (strong, nonatomic) PGTilingOverlay *tilingOverlay;

@end

@implementation PGPreviewViewController

+ (void)presentPreviewPhotoFrom:(UIViewController *)currentViewController andSource:(NSString *)source animated:(BOOL)animated
{
    [self presentPreviewPhotoFrom:currentViewController andSource:source media:nil animated:animated];
}

+ (void)presentPreviewPhotoFrom:(UIViewController *)currentViewController andSource:(NSString *)source media:(HPPRMedia *)media animated:(BOOL)animated
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.source = source;
    previewViewController.media = media;

    [currentViewController presentViewController:previewViewController animated:animated completion:nil];
}

+ (void)presentCameraFrom:(UIViewController *)currentViewController animated:(BOOL)animated
{
    [[PGPhotoSelection sharedInstance] clearSelection];

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

    self.wasDrawerOpenedByUser = NO;

    self.editButton.titleLabel.font = [UIFont HPSimplifiedLightFontWithSize:20];
    self.editButton.titleLabel.tintColor = [UIColor whiteColor];

    self.editButton.hidden = !IS_OS_9_OR_LATER;

    self.imglyManager = [[PGImglyManager alloc] init];

    if ([PGPhotoSelection sharedInstance].hasMultiplePhotos) {
        self.drawer.showCopies = NO;
        self.drawer.showTiling = NO;
        self.drawer.alwaysShowPrintQueue = YES;
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

    self.operationQueue = [[NSOperationQueue alloc] init];

    self.tilingOverlay = [[PGTilingOverlay alloc] init];
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
        visibleGestureView.editedImage = [visibleGestureView captureEditedImage];
    }

    if ([[MPBTPrintManager sharedInstance] queueSize] > 0 && self.carouselView.visibleItemViews.count > 0) {
        [self peekDrawerAnimated:YES];
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

    if ([PGPartyGuestManager sharedInstance].connected) {
        [self.printButton setImage:[UIImage imageNamed:@"previewPrinterParty"] forState:UIControlStateNormal];
    } else if (numberOfPairedSprockets > 0 || [PGLinkSettings fakePrintEnabled]) {
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

    self.photoEditViewController = [[IMGLYPhotoEditViewController alloc] initWithPhoto:photoToEdit menuItems:menuItems configuration:configuration];

    self.photoEditViewController.delegate = self;

    IMGLYToolbarController *toolController = [[IMGLYToolbarController alloc] init];
    toolController.toolbar.backgroundColor = [UIColor HPRowColor];

    [toolController pushViewController:self.photoEditViewController animated:NO completion:nil];
    [toolController setModalPresentationStyle:UIModalPresentationOverFullScreen];
    [toolController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

    self.imglyManager.photoEditViewController = self.photoEditViewController;

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
    NSUInteger buttonAlphaValue = show ? 0 : 1;
    NSUInteger multiSelectLabelAlphaValue = show ? 0 : [PGPhotoSelection sharedInstance].hasMultiplePhotos;
    CGRect frame = self.topView.frame;
    if (!show) {
        frame.origin.y -= frame.size.height;
    }

    [UIView animateWithDuration:0.5F animations:^{
        self.closeButton.alpha = buttonAlphaValue;
        self.editButton.alpha = buttonAlphaValue;
        self.numberOfSelectedPhotos.alpha = multiSelectLabelAlphaValue;
        self.imageSavedView.frame = frame;
    }];
}

- (void)savePhoto:(NSArray *)images index:(NSInteger)index withCompletion:(void (^)(BOOL, NSArray<UIImage *> *))completion
{
    __block NSArray *savedImages = images;
    __block NSInteger idx = index;

    UIImage *image = [savedImages objectAtIndex:idx++];

    if (image) {
        [PGSavePhotos saveImage:image completion:^(BOOL success, PHAsset* asset) {
            if (success && [savedImages count] > idx) {
                [self savePhoto:savedImages index:idx withCompletion:completion];
            } else if (completion) {
                completion(success, images);
            }
        }];

    } else if (completion) {
        completion(NO, images);
    }
}

- (void)saveSelectedPhotosWithCompletion:(void (^)(BOOL, NSArray<UIImage *> *))completion
{
    NSArray *images = [self editedImagesSelected];
    if (images.count > 0) {
        [self savePhoto:images index:0 withCompletion:completion];
    }
}

- (void)reloadCarouselItems
{
    if (self.carouselView.visibleItemViews.count > 0) {
        [self.view layoutIfNeeded];
        [self.carouselView reloadData];
    }
}

- (void)reloadCarouselItemsAndEditedImage
{
    [self reloadCarouselItems];

    if (self.carouselView.visibleItemViews.count > 0) {
        [self currentEditedImage];
    }
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

- (NSString *)numberOfPrintsAddedString:(NSInteger)numberOfPrintsAdded
{
    NSString *printString = NSLocalizedString(@"%ld print added to the queue, %ld total", @"This will be formatted as '1 print added to the queue, 7 total'");
    if (numberOfPrintsAdded > 1) {
        printString = NSLocalizedString(@"%ld prints added to the queue, %ld total", @"This will be formatted as '3 prints added to the queue, 7 total'");
    }

    NSString *title = [NSString stringWithFormat:printString, (long)numberOfPrintsAdded, (long)[MPBTPrintManager sharedInstance].queueSize];

    return title;
}

- (NSString *)numberOfPrintsAddedAndInProgressString:(NSInteger)numberOfPrintsAdded
{
    NSString *printString = NSLocalizedString(@"%ld prints added to the queue, 1 in progress", @"This will be formatted as '3 prints added to the queue, 1 in progress'");
    NSString *title = [NSString stringWithFormat:printString, (long)numberOfPrintsAdded];

    return title;
}

- (void)showAddToQueueAlert:(NSInteger)numberOfPrintsAdded withCompletion:(void (^)())completion
{
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Sprocket Printer Not Connected, %@", nil), [self numberOfPrintsAddedString:numberOfPrintsAdded]];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:NSLocalizedString(@"Your prints will start when the sprocket printer is on and bluetooth connected.", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *printQueueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Print Queue", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[PGPrintQueueManager sharedInstance] showPrintQueueStatusFromViewController:self];
        [self peekDrawerAnimated:YES];
    }];

    [alert addAction:printQueueAction];

    UIAlertAction *printHelpAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Print Help", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self peekDrawerAnimated:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        PGSetupSprocketViewController *setupViewController = (PGSetupSprocketViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGSetupSprocketViewController"];
        [setupViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [setupViewController setModalPresentationStyle:UIModalPresentationOverFullScreen];
        [self presentViewController:setupViewController animated:YES completion:nil];
    }];

    [alert addAction:printHelpAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self peekDrawerAnimated:YES];
    }];

    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:completion];
}

- (NSMutableArray<UIImage *> *)editedImagesSelected
{
    NSMutableArray *editedImages = [NSMutableArray array];
    if (self.drawer.tilingOption == PGTilingOverlayOptionSingle) {
        for (PGGesturesView *gestureView in self.gesturesViews) {
            if (gestureView.isSelected && gestureView.editedImage) {
                [editedImages addObject:gestureView.editedImage];
            }
        }
    } else {
        PGGesturesView *gestureView = self.gesturesViews[0];
        editedImages = [self generateTiles:gestureView rotatingLastRow:NO];
    }

    return editedImages;
}

- (void)handleSaveAndSharePhotoPrintMetrics:(NSArray<UIImage *> *)savedPhotos offRamp:(NSString *)offRamp
{
    if (![PGPhotoSelection sharedInstance].isInSelectionMode && self.drawer.tilingOption == PGTilingOverlayOptionSingle) {
        [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offRamp
                                                         printItem:self.printItem
                                                      extendedInfo:[self extendedMetricsByGestureView:(PGGesturesView *)self.carouselView.currentItemView]];
    } else if (self.drawer.tilingOption != PGTilingOverlayOptionSingle) {
        NSString *offRampMetric = [NSString stringWithFormat:@"%@-Tile", offRamp];
        for (UIImage *tile in savedPhotos) {
            MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:tile];
            printItem.layout = [self layout];

            [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offRampMetric
                                                             printItem:printItem
                                                          extendedInfo:[self extendedMetricsByGestureView:self.gesturesViews[0]]];
        }
    } else {
        NSUInteger selectedPhotosCount = 0;
        NSString *offRampMetric = [NSString stringWithFormat:@"%@-Multi", offRamp];
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
    }
}

#pragma mark - Drawer Methods

- (void)setDrawerHeightAnimated:(BOOL)animated
{
    if (self.drawer.isOpened || self.drawer.isPeeking) {
        [self.drawer configureShowPrintQueue];
    }

    self.containerViewHeightConstraint.constant = [self.drawer drawerHeight];

    if (animated) {
        [UIView animateWithDuration:kDrawerAnimationDuration animations:^{
            [self reloadCarouselItems];
        } completion:^(BOOL finished) {
            [self reloadCarouselItemsAndEditedImage];
            if (!self.drawer.isOpened) {
                [self.drawer configureShowPrintQueue];
            }
        }];
    } else {
        [self reloadCarouselItemsAndEditedImage];
        if (!self.drawer.isOpened) {
            [self.drawer configureShowPrintQueue];
        }
    }
}

- (void)peekDrawerAnimated:(BOOL)animated
{
    if (self.drawer.isOpened || self.drawer.isPeeking) {
        return;
    }

    self.drawer.isOpened = NO;
    self.drawer.isPeeking = YES;

    [self setDrawerHeightAnimated:animated];
}

- (void)closeDrawerAnimated:(BOOL)animated
{
    if (!self.drawer.isOpened && !self.drawer.isPeeking) {
        return;
    }

    self.drawer.isOpened = NO;
    self.drawer.isPeeking = NO;
    self.wasDrawerOpenedByUser = NO;

    [self setDrawerHeightAnimated:animated];
}

- (void)openDrawerAnimated:(BOOL)animated
{
    if (self.drawer.isOpened) {
        return;
    }

    self.drawer.isOpened = YES;
    self.drawer.isPeeking = NO;

    [self setDrawerHeightAnimated:animated];
}

#pragma mark - PGPreviewDrawerDelegate

- (void)pgPreviewDrawer:(PGPreviewDrawerViewController *)drawer didTapButton:(UIButton *)button
{
    drawer.isPeeking = NO;
    self.wasDrawerOpenedByUser = drawer.isOpened;
    [self setDrawerHeightAnimated:YES];
}

- (void)pgPreviewDrawer:(PGPreviewDrawerViewController *)drawer didDrag:(UIPanGestureRecognizer *)gesture
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
        if (drawer.isPeeking) {
            threshold = [drawer drawerHeightPeeking];
        }

        drawer.isPeeking = NO;
        drawer.isOpened = self.containerViewHeightConstraint.constant > threshold;
        self.wasDrawerOpenedByUser = drawer.isOpened;

        [self setDrawerHeightAnimated:NO];
    }
}

- (void)pgPreviewDrawer:(PGPreviewDrawerViewController *)drawer didChangeTillingOption:(PGTilingOverlayOption)tilingOption
{
    if (tilingOption == PGTilingOverlayOptionSingle) {
        [self.tilingOverlay removeOverlay];
        return;
    }

    UIView *gestureView = self.gesturesViews.firstObject;
    if (!gestureView) {
        return;
    }

    [self.tilingOverlay addTilingOverlay:tilingOption toView:gestureView];
}

- (void)pgPreviewDrawerDidTapPrintQueue:(PGPreviewDrawerViewController *)drawer
{
    [[PGPrintQueueManager sharedInstance] showPrintQueueStatusFromViewController:self];
}

- (void)pgPreviewDrawerDidClearQueue:(PGPreviewDrawerViewController *)drawer
{
    if (!self.wasDrawerOpenedByUser) {
        [self closeDrawerAnimated:YES];
    }
}

#pragma mark - IMGLYPhotoEditViewControllerDelegate

- (void)photoEditViewController:(IMGLYPhotoEditViewController *)photoEditViewController didSaveImage:(UIImage *)image imageAsData:(NSData *)data {
    PGGesturesView *currentGesturesView = self.gesturesViews[self.carouselView.currentItemIndex];
    [currentGesturesView setImage:image];

    currentGesturesView.scrollView.transform = CGAffineTransformIdentity;
    currentGesturesView.totalRotation = 0.0F;
    currentGesturesView.scrollView.zoomScale = currentGesturesView.minimumZoomScale;

    [self clearPhotoEditor];
    [self dismissViewControllerAnimated:YES completion:nil];

    self.didChangeProject = YES;
    [self.carouselView reloadItemAtIndex:self.carouselView.currentItemIndex animated:YES];

    [self currentEditedImage];
}

- (void)photoEditViewControllerDidCancel:(IMGLYPhotoEditViewController *)photoEditViewController {
    [self clearPhotoEditor];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditViewControllerDidFailToGeneratePhoto:(IMGLYPhotoEditViewController *)photoEditViewController {
    MPLogError(@"photoEditViewControllerDidFailToGeneratePhoto:%@", photoEditViewController);
    [self clearPhotoEditor];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearPhotoEditor
{
    self.photoEditViewController = nil;
    self.imglyManager.photoEditViewController = nil;
}

#pragma mark - Camera Handlers

- (void)closePreviewAndCamera {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPGPreviewViewClosed object:nil];
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
    gesturesView.delegate = self;
    self.gesturesViews = [NSMutableArray arrayWithObject:gesturesView];

    [PGAnalyticsManager sharedManager].photoSource = self.source;
    [self.carouselView reloadData];
}

+ (NSString *)cameraSource
{
    return @"Camera";
}

#pragma mark - PGGesture Delegate

- (void)imageEdited:(PGGesturesView *)gesturesView
{
    self.didChangeProject = YES;
}

- (void)handleLongPress:(PGGesturesView *)gesturesView
{

}

#pragma mark - Bottom Menu Handlers

- (IBAction)didTouchUpInsideDownloadButton:(id)sender
{
    [self showDownloadingImagesAlertWithCompletion:^{
        [self closeDrawerAnimated:NO];
        [self saveSelectedPhotosWithCompletion:^(BOOL success, NSArray<UIImage *> *selectedPhotos) {
            if (success) {
                [self handleSaveAndSharePhotoPrintMetrics:selectedPhotos offRamp:NSStringFromClass([PGSaveToCameraRollActivity class])];

                if (![PGPhotoSelection sharedInstance].isInSelectionMode && self.drawer.tilingOption == PGTilingOverlayOptionSingle) {
                    [[PGAnalyticsManager sharedManager] trackSaveProjectActivity:kEventSaveProjectPreview];
                } else if (self.drawer.tilingOption != PGTilingOverlayOptionSingle) {
                    [[PGAnalyticsManager sharedManager] trackMultiSaveProjectActivity:[NSString stringWithFormat:@"%@-Tile", kEventSaveProjectPreview] numberOfPhotos:selectedPhotos.count];
                } else {
                    [[PGAnalyticsManager sharedManager] trackMultiSaveProjectActivity:[NSString stringWithFormat:@"%@-Multi", kEventSaveProjectPreview] numberOfPhotos:selectedPhotos.count];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageSavedLabel.text = NSLocalizedString(@"Saved to sprocket folder", nil);
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

        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            __weak PGPreviewViewController *weakSelf = self;
            [self saveSelectedPhotosWithCompletion:^(BOOL success, NSArray<UIImage *> *selectedPhotos) {
                if (success) {
                    [weakSelf handleSaveAndSharePhotoPrintMetrics:selectedPhotos offRamp:NSStringFromClass([PGSaveToCameraRollActivity class])];

                    if (![PGPhotoSelection sharedInstance].isInSelectionMode && weakSelf.drawer.tilingOption == PGTilingOverlayOptionSingle) {
                        [[PGAnalyticsManager sharedManager] trackDismissEditActivity:kEventDismissEditSaveAction
                                                                              source:kEventDismissEditCloseLabel];
                    } else if (weakSelf.drawer.tilingOption != PGTilingOverlayOptionSingle) {
                        [[PGAnalyticsManager sharedManager] trackMultiSaveProjectActivity:[NSString stringWithFormat:@"%@-Tile", kEventSaveProjectDismiss] numberOfPhotos:selectedPhotos.count];
                    } else {
                        [[PGAnalyticsManager sharedManager] trackMultiSaveProjectActivity:[NSString stringWithFormat:@"%@-Multi", kEventSaveProjectDismiss] numberOfPhotos:selectedPhotos.count];
                    }

                    [weakSelf closePreviewAndCamera];
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
    [self closeDrawerAnimated:NO];
    [self showImgly];

    if (drawerWasOpened) {
        [self openDrawerAnimated:NO];
    }
}

- (IBAction)didTouchUpInsidePrinterButton:(id)sender
{
    [self showDownloadingImagesAlertWithCompletion:^{
        BOOL wasDrawerOpened = self.drawer.isOpened;

        [self closeDrawerAnimated:NO];
        if ([MP sharedInstance].numberOfPairedSprockets > 0) {
            [[MP sharedInstance] presentBluetoothDeviceSelectionFromController:self animated:YES completion:^(BOOL success) {
                [self printWithDrawerOpened:wasDrawerOpened andPrinterConnectedStatus:success];
            }];
        } else {
            [self printWithDrawerOpened:wasDrawerOpened andPrinterConnectedStatus:NO];
        }
    }];
}

- (IBAction)didTouchUpInsideShareButton:(id)sender
{
    [self showDownloadingImagesAlertWithCompletion:^{
        [self closeDrawerAnimated:NO];
        [[MP sharedInstance] closeAccessorySession];

        [self presentActivityViewControllerWithActivities:nil];
    }];
}

- (BOOL)isWatermarkingEnabledForMedia:(HPPRMedia *)media {
    return ([PGLinkSettings linkEnabled] && [media socialMediaImageUrl]);
}

#pragma mark - Print preparation

- (NSArray *)multiSelectPrintAssets:(NSArray<PGGesturesView *> *)selectedViews
{
    NSMutableArray *assets = [NSMutableArray array];
    for (PGGesturesView *gestureView in selectedViews) {
        gestureView.editedImage = [gestureView captureEditedImage];
        [assets addObject:@{ @"image":gestureView.editedImage, @"view":gestureView }];
    }

    return assets;
}

- (NSArray *)tilePrintAssets:(NSArray<PGGesturesView *> *)selectedViews
{
    if (selectedViews.count > 1) {
        PGLogError(@"Unexpected multi-select with tile option selected");
    }

    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray<UIImage *> *tiles = [self generateTiles:selectedViews[0] rotatingLastRow:YES];
    for (UIImage *tile in tiles) {
        [assets addObject:@{ @"image":tile, @"view":selectedViews[0] }];
    }

    return assets;
}

- (NSArray *)generatePrintAssets:(NSArray<PGGesturesView *> *)selectedViews
{
    NSArray *assets = nil;

    if (self.drawer.tilingOption != PGTilingOverlayOptionSingle) {
        assets = [self tilePrintAssets:selectedViews];
    } else {
        assets = [self multiSelectPrintAssets:selectedViews];
    }

    return assets;
}

- (void)printWithDrawerOpened:(BOOL)wasDrawerOpened andPrinterConnectedStatus:(BOOL)isPrinterConnected
{
    [self.operationQueue waitUntilAllOperationsAreFinished];
    self.operationQueue.suspended = YES;

    NSArray *offRampAndOrigin = [self offrampAndOriginByPrinterConnectedStatus:isPrinterConnected];
    NSString *origin = offRampAndOrigin[0];
    NSString *offRamp = offRampAndOrigin[1];
    NSInteger numberOfCopies = self.drawer.numberOfCopies;
    NSOperation *lastOperation = nil;

    NSMutableArray<PGGesturesView *> *selectedViews = [self gestureViewsSelected];
    if (numberOfCopies > 1) {
        for (NSInteger i = 1; i < numberOfCopies; i++) {
            [selectedViews addObject:selectedViews.firstObject];
        }
    }

    NSArray *printAssets = [self generatePrintAssets:selectedViews];
    if (nil == printAssets || 0 == printAssets.count) {
        PGLogError(@"PRINTING: Unable to generate assets to print");
        return;
    }

    self.assetCount = printAssets.count;
    self.assetNumber = 0;
    self.addToQueueCount = 0;

    for (NSDictionary *asset in printAssets) {

        UIImage *image = [asset objectForKey:@"image"];
        PGGesturesView *gestureView = [asset objectForKey:@"view"];

        NSMutableDictionary *extendedMetrics = [[NSMutableDictionary alloc] init];
        [extendedMetrics addEntriesFromDictionary:[self extendedMetricsByGestureView:gestureView]];
        PGPrintProcessingInfo *info = [[PGPrintProcessingInfo alloc] initWithImage:image
                                                                             media:gestureView.media
                                                                            origin:origin
                                                                           offramp:offRamp
                                                                            copies:numberOfCopies
                                                                         connected:isPrinterConnected
                                                                   extendedMetrics:extendedMetrics];

        // PRE-PROCESSOR(S)
        lastOperation = [self queuePreProcessorWithInfo:info dependency:lastOperation];

        // PARTY PRINT
        if ([PGPartyGuestManager sharedInstance].connected) {
            lastOperation = [self queuePartyPrintInfo:info dependency:lastOperation];

        // FAKE PRINT
        } else if ([PGLinkSettings fakePrintEnabled]) {
            lastOperation = [self queueFakePrintWithInfo:info dependency:lastOperation];

        // DIRECT PRINT
        } else if (1 == printAssets.count && ([MPBTPrintManager sharedInstance].status == MPBTPrinterManagerStatusEmptyQueue && isPrinterConnected)) {
            lastOperation = [self queueDirectPrintWithInfo:info dependency:lastOperation];

        // PRINT QUEUE
        } else {
            lastOperation = [self queueAddToQueueWithPrintInfo:info dependency:lastOperation];
        }
    }

    // PRINTING COMPLETE
    [self queuePrintingCompleteWithConnected:isPrinterConnected drawerOpen:wasDrawerOpened dependency:lastOperation];

    self.operationQueue.suspended = NO;

}

- (void)resumePrintingWithDrawerOpened:(BOOL)wasDrawerOpened andNumberOfPrintsAddedToQueue:(NSInteger)numberOfPrintsAdded;
{
    [[MPBTPrintManager sharedInstance] resumePrintQueue:^(MPBTPrinterManagerStatus status, NSInteger progress, NSInteger errorCode) {
        return [self handlePrintQueueStatus:status progress:progress printsAdded:numberOfPrintsAdded error:errorCode];
    }];

    if (wasDrawerOpened) {
        [self openDrawerAnimated:NO];
    }
}

- (void)trackNumberOfPrintsAddedToQueue:(NSUInteger)queueSize
{
    NSString *action = kEventPrintQueueAddSingleAction;
    if ([MPBTPrintManager sharedInstance].originalQueueSize > 1) {
        action = kEventPrintQueueAddMultiAction;
    }

    if (self.drawer.numberOfCopies > 1) {
        action = kEventPrintQueueAddCopiesAction;
    }

    if (self.drawer.tilingOption != PGTilingOverlayOptionSingle) {
        action = kEventPrintQueueAddTileAction;
    }

    [[PGAnalyticsManager sharedManager] trackPrintQueueAction:action
                                                      queueId:[MPBTPrintManager sharedInstance].queueId
                                                    queueSize:queueSize];
}

- (NSArray<NSString *> *)offrampAndOriginByPrinterConnectedStatus:(BOOL)isPrinterConnected
{
    NSUInteger selectedViewsCount = [self gestureViewsSelected].count;
    NSUInteger numberOfCopies = self.drawer.numberOfCopies;
    NSString *origin = @"";
    NSString *offRamp = @"";

    if (selectedViewsCount > 1) {
        origin = kMetricsOriginMulti;
        offRamp = kMetricsOffRampQueueAddMulti;
    } else if (numberOfCopies > 1) {
        origin = kMetricsOriginCopies;
        offRamp = kMetricsOffRampQueueAddCopies;
    } else if ((selectedViewsCount == 1) && (numberOfCopies == 1)) {
        if ([MPBTPrintManager sharedInstance].status == MPBTPrinterManagerStatusEmptyQueue && isPrinterConnected) {
            offRamp = kMetricsOffRampPrintNoUISingle;
            if (self.drawer.tilingOption == PGTilingOverlayOptionSingle) {
                origin = kMetricsOriginSingle;
            } else {
                origin = kMetricsOriginTile;
            }

            if ([[PGPhotoSelection sharedInstance] isInSelectionMode]) {
                offRamp = kMetricsOffRampPrintNoUIMulti;
            }
        } else {
            if (self.drawer.tilingOption == PGTilingOverlayOptionSingle) {
                origin = kMetricsOriginSingle;
                offRamp = kMetricsOffRampQueueAddSingle;
            } else {
                origin = kMetricsOriginTile;
                offRamp = kMetricsOffRampQueueAddTile;
            }
        }
    }

    return @[origin, offRamp];
}

- (NSMutableArray<UIImage *> *)generateTiles:(PGGesturesView*)gestureView rotatingLastRow:(BOOL)shouldRotate {
    NSMutableArray<UIImage *> *tiles = [[NSMutableArray alloc] init];
    UIImage* currentImage = [gestureView captureEditedImage];
    NSArray<NSNumber *> *selectedTiles = self.tilingOverlay.selectedTiles;

    NSInteger tilesColumnCount;
    NSInteger tilesRowCount;
    NSInteger scale;
    if (self.drawer.tilingOption == PGTilingOverlayOption2x2) {
        tilesColumnCount = 2;
        tilesRowCount = 2;
        scale = 2;
    } else if (self.drawer.tilingOption == PGTilingOverlayOption3x3){
        tilesColumnCount = 3;
        tilesRowCount = 3;
        scale = 3;
    } else {
        [tiles addObject:currentImage];
        return tiles;
    }

    CGFloat imgWidth = currentImage.size.width * currentImage.scale / scale;
    CGFloat imgheight = currentImage.size.height * currentImage.scale / scale;
    CGFloat compensatedWidth = imgWidth * 1.012;
    CGFloat compensatedHeight = imgheight * 1.012;

    NSUInteger indexCount = 0;
    for (int y = 0; y < tilesRowCount; y++) {
        for (int x = 0; x < tilesColumnCount; x++) {
            if (![selectedTiles containsObject:[NSNumber numberWithUnsignedInteger:indexCount++]]) {
                continue;
            }

            UIImage *tileImage;
            CGFloat adjX = 0;
            CGFloat adjY = 0;
            if (y > 0) {
                adjY = compensatedHeight - imgheight;
            }
            if (x > 0) {
                adjX = compensatedWidth - imgWidth;
            }

            CGFloat startX = (x * imgWidth) - adjX;
            CGFloat startY = (y * imgheight) - adjY;
            CGRect imageRect = CGRectMake(startX, startY, compensatedWidth, compensatedHeight);
            CGImageRef imageRef = CGImageCreateWithImageInRect(currentImage.CGImage, imageRect);
            if (y == tilesRowCount-1 && shouldRotate) {
                tileImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationDown];
            } else {
                tileImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
            }
            [tiles addObject:tileImage];
            CGImageRelease(imageRef);
        }
    }
    return tiles;
}

-(MPBTImageProcessor *) createPrintProcessorFromMedia:(HPPRMedia*)media {
    PGPayoffProcessor * processor = nil;
    if ([PGLinkSettings linkEnabled] && media ) {
        PGMetarMedia * meta = [PGMetarMedia metaFromHPPRMedia:media];
        // if we created payoff
        if( meta ) {
            processor = [PGPayoffProcessor processorWithMetadata:meta];
        }
    }
    return processor;
}

- (void)showProgressView {
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
}


- (void)setProgressSubtext
{
    if (self.assetCount > 1) {
        [self.progressView setSubText:[NSString stringWithFormat:@"%lu / %lu", (long)self.assetNumber, (long)self.assetCount]];
    } else {
        [self.progressView setSubText:nil];
    }
}

-(void) handleProcessorStatus:(MPBTImageProcessor*) processor progress:(CGFloat)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showProgressView];
        [self.progressView setProgress:progress];
        [self.progressView setText:processor.progressText];
        [self setProgressSubtext];
    });
}

- (void)handlePartySendProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showProgressView];
        [self.progressView setProgress:progress];
        [self.progressView setText:NSLocalizedString(@"Sending to Party Printer", @"Indicates that the phone is sending the photo(s) to the party printer")];
        [self setProgressSubtext];
    });
}

- (BOOL)handlePrintQueueStatus:(MPBTPrinterManagerStatus)status progress:(NSInteger)progress printsAdded:(NSInteger)numberOfPrintsAdded error:(NSInteger)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{

        if (errorCode > 0) {
            PGLogDebug(@"PRINT STATUS: ERROR: %lu", (long)errorCode);
            [self dismissProgressView];

            if ([[MPBTPrintManager sharedInstance] queueSize] > 0) {
                [self peekDrawerAnimated:YES];
            }

        } else if (status == MPBTPrinterManagerStatusResumingPrintQueue) {
            PGLogDebug(@"PRINT STATUS: RESUMING PRINT QUEUE");
        } else if (status == MPBTPrinterManagerStatusSendingPrintJob) {
            PGLogDebug(@"PRINT STATUS: SENDING JOB: %lu%%", (long)progress);
            [self showProgressView];
            [self.progressView setProgress:(((CGFloat)progress) / 100.0F) * 0.9F];
            [self.progressView setText:NSLocalizedString(@"Sending to sprocket printer", @"Indicates that the phone is sending an image to the printer")];
            if (numberOfPrintsAdded > 0) {
                [self.progressView setSubText:[self numberOfPrintsAddedString:numberOfPrintsAdded]];
            } else {
                [self.progressView setSubText:nil];
            }
        } else if (status == MPBTPrinterManagerStatusPrinting) {
            PGLogDebug(@"PRINT STATUS: PRINTING");
            [self.progressView setProgress:1.0F];
            [self dismissProgressView];

        } else if (status == MPBTPrinterManagerStatusIdle) {
            PGLogDebug(@"PRINT STATUS: IDLE");
            // User paused the print queue
            [self dismissProgressView];
        }

    });

    BOOL progressViewDismissed = (errorCode > 0 || status == MPBTPrinterManagerStatusPrinting || status == MPBTPrinterManagerStatusIdle);

    return !progressViewDismissed;
}

- (void)dismissProgressView {
    if (self.progressView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.progressView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.progressView removeFromSuperview];
            self.progressView = nil;

            if ([MPBTPrintManager sharedInstance].originalQueueSize > 1) {
                [self peekDrawerAnimated:YES];
            }
        }];
    }
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
    if (self.source == [PGPreviewViewController cameraSource]) {
        [PGAnalyticsManager sharedManager].photoSource = self.source;
    } else {
        [PGAnalyticsManager sharedManager].photoSource = gestureView.media.photoProvider.name;
    }

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
        NSArray<UIImage *> *selectedImages = [self editedImagesSelected];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:selectedImages applicationActivities:applicationActivities];

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

            NSString *offRamp = activityType;

            if (printActivity) {
                offRamp = [MPPrintManager printOfframp];
                [[PGAnalyticsManager sharedManager] trackPrintRequest:kEventPrintShareLabel];
            }

            if (!offRamp) {
                PGLogError(@"Missing offramp key for share activity");
                offRamp = @"Unknown";
            }

            if (completed) {
                if (!printActivity) {
                    [weakSelf handleSaveAndSharePhotoPrintMetrics:selectedImages offRamp:offRamp];
                    [weakSelf trackShareActivity:offRamp withResult:kEventResultSuccess numbeOfPhotos:selectedImages.count];
                } else {
                    weakSelf.currentOfframp = offRamp;
                }
            } else {
                if (activityType) {
                    [weakSelf trackShareActivity:offRamp withResult:kEventResultCancel numbeOfPhotos:selectedImages.count];
                }
            }
        };

        activityViewController.popoverPresentationController.sourceRect = self.shareButton.bounds;
        activityViewController.popoverPresentationController.sourceView = self.shareButton;
        activityViewController.popoverPresentationController.delegate = self;

        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

- (void)trackShareActivity:(NSString *)offRamp withResult:(NSString *)result numbeOfPhotos:(NSUInteger)numberOfPhotos
{
    if (![PGPhotoSelection sharedInstance].isInSelectionMode && self.drawer.tilingOption == PGTilingOverlayOptionSingle) {
        [[PGAnalyticsManager sharedManager] trackShareActivity:offRamp withResult:result];
    } else if (self.drawer.tilingOption != PGTilingOverlayOptionSingle) {
        NSString *offRampMetric = [NSString stringWithFormat:@"%@-Tile", offRamp];
        [[PGAnalyticsManager sharedManager] trackShareActivity:offRampMetric withResult:result andNumberOfPhotos:numberOfPhotos];
    } else {
        NSString *offRampMetric = [NSString stringWithFormat:@"%@-Multi", offRamp];
        [[PGAnalyticsManager sharedManager] trackShareActivity:offRampMetric withResult:result andNumberOfPhotos:numberOfPhotos];
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

#pragma mark - Print Processing

- (NSOperation *)queuePreProcessorWithInfo:(PGPrintProcessingInfo *)info dependency:(NSOperation *)dependency
{
    NSBlockOperation *preProcessStartOperation = [NSBlockOperation blockOperationWithBlock:^{
        PGLogDebug(@"PREVIEW CONTROLLER: OPERATION: PRE-PROCESSOR(S) START");
        self.assetNumber++;
    }];
    if (nil != dependency) {
        [preProcessStartOperation addDependency:dependency];
    }
    [self.operationQueue addOperation:preProcessStartOperation];

    NSBlockOperation *preProcessCompleteOperation = [NSBlockOperation blockOperationWithBlock:^{
        PGLogDebug(@"PREVIEW CONTROLLER: OPERATION: PRE-PROCESSOR(S) COMPLETE");
    }];
    [preProcessCompleteOperation addDependency:preProcessStartOperation];

    MPBTImageProcessor *processor = nil;
    if ([PGLinkSettings linkEnabled]) {
        processor = [self createPrintProcessorFromMedia:info.media];
        if (nil != processor) {
            [preProcessStartOperation addExecutionBlock:^{
                NSDictionary *options = @{ kMPBTImageProcessorLocalIdentifierKey : [[PGPayoffManager sharedInstance] offlineID] };
                MPBTImagePreprocessorManager * mg = [MPBTImagePreprocessorManager createWithProcessors:@[processor] options:options];
                [mg processImage:info.image statusUpdate:^(NSUInteger processorIndex, double progress) {
                    [self handleProcessorStatus:mg.processors[processorIndex] progress:progress];
                } complete:^(NSError *error, UIImage *result) {
                    if (nil == error) {
                        info.image = result;
                    } else {
                        PGLogDebug(@"PREVIEW CONTROLLER: PRE-PROCESSOR: ERROR: %@", error);
                    }
                    [self.operationQueue addOperation:preProcessCompleteOperation];
                }];
            }];
        }
    }
    if (nil == processor) {
        [self.operationQueue addOperation:preProcessCompleteOperation];
    }

    return preProcessCompleteOperation;
}

- (NSOperation *)queuePartyPrintInfo:(PGPrintProcessingInfo *)info dependency:(NSOperation *)dependency
{
    NSBlockOperation *partyPrintStartOperation = [NSBlockOperation blockOperationWithBlock:^{
        PGLogDebug(@"PREVIEW CONTROLLER: OPERATION: PARTY PRINT START");
    }];
    [partyPrintStartOperation addDependency:dependency];
    [self.operationQueue addOperation:partyPrintStartOperation];

    NSBlockOperation *partyPrintCompleteOperation = [NSBlockOperation blockOperationWithBlock:^{
        PGLogDebug(@"PREVIEW CONTROLLER: OPERATION: PARTY PRINT COMPLETE");
    }];
    [partyPrintCompleteOperation addDependency:partyPrintStartOperation];

    [partyPrintStartOperation addExecutionBlock:^{
        [[PGPartyGuestManager sharedInstance] sendImage:info.image progress:^(CGFloat progress) {
            [self handlePartySendProgress:progress];
        } completion:^(NSError *error) {
            if (nil != error) {
                PGLogError(@"PREVIEW CONTROLLER: PARTY PRINT ERROR: %@", error);
            }
            [self.operationQueue addOperation:partyPrintCompleteOperation];
        }];
    }];

    return partyPrintCompleteOperation;
}

- (NSOperation *)queueFakePrintWithInfo:(PGPrintProcessingInfo *)info dependency:(NSOperation *)dependency
{
    NSBlockOperation *fakePrintStartOperation = [NSBlockOperation blockOperationWithBlock:^{
        PGLogDebug(@"PREVIEW CONTROLLER: OPERATION: FAKE PRINT START");
    }];
    [fakePrintStartOperation addDependency:dependency];
    [self.operationQueue addOperation:fakePrintStartOperation];

    NSBlockOperation *fakePrintCompleteOperation = [NSBlockOperation blockOperationWithBlock:^{
        PGLogDebug(@"PREVIEW CONTROLLER: OPERATION: FAKE PRINT COMPLETE");
    }];
    [fakePrintCompleteOperation addDependency:fakePrintStartOperation];

    __weak __typeof(self)weakSelf = self;
    void (^saveImage)() = ^{
        [PGSavePhotos saveImageFake:info.image completion:^(BOOL success, PHAsset * asset) {
            if (success) {
                PGLogDebug(@"FAKE PRINT: IMAGE SAVED");
            } else {
                PGLogError(@"FAKE PRINT: SAVE FAILED");
            }
            [weakSelf.operationQueue addOperation:fakePrintCompleteOperation];
        }];
    };

    [fakePrintStartOperation addExecutionBlock:^{
        if ([PGSavePhotos savePhotos]) {
            saveImage();
        } else {
            [PGSavePhotos promptToSavePhotos:self completion:^(BOOL savePhotos) {
                if (savePhotos) {
                    saveImage();
                } else {
                    PGLogDebug(@"FAKE PRINT: SAVE SKIPPED");
                    [self.operationQueue addOperation:fakePrintCompleteOperation];
                }
            }];
        }
    }];

    return fakePrintCompleteOperation;
}

- (NSOperation *)queueDirectPrintWithInfo:(PGPrintProcessingInfo *)info dependency:(NSOperation *)dependency
{
    NSBlockOperation *directPrintStartOperation = [NSBlockOperation blockOperationWithBlock:^{
        PGLogDebug(@"PREVIEW CONTROLLER: OPERATION: DIRECT PRINT START");
    }];
    [directPrintStartOperation addDependency:dependency];
    [self.operationQueue addOperation:directPrintStartOperation];

    NSBlockOperation *directPrintCompleteOperation = [NSBlockOperation blockOperationWithBlock:^{
        PGLogDebug(@"PREVIEW CONTROLLER: OPERATION: DIRECT PRINT COMPLETE");
    }];
    [directPrintCompleteOperation addDependency:directPrintStartOperation];

    [directPrintStartOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *metrics = [self metricsForInfo:info];
            [[MPBTPrintManager sharedInstance] printDirect:info.printItem metrics:metrics statusUpdate:^BOOL(MPBTPrinterManagerStatus status, NSInteger progress, NSInteger errorCode) {
                BOOL busy = [self handlePrintQueueStatus:status progress:progress printsAdded:0 error:errorCode];
                if (!busy) {
                    [self.operationQueue addOperation:directPrintCompleteOperation];
                }
                return busy;
            }];
        });
    }];

    return directPrintCompleteOperation;
}

- (NSOperation *)queueAddToQueueWithPrintInfo:(PGPrintProcessingInfo *)info dependency:(NSOperation *)dependency
{
    NSBlockOperation *queueOperation = [NSBlockOperation blockOperationWithBlock:^{
        PGLogDebug(@"PREVIEW CONTROLLER: OPERATION: QUEUE");

        @synchronized ([MPBTPrintManager sharedInstance]) {
            NSMutableDictionary *metrics = [self metricsForInfo:info];
            [metrics setObject:@([MPBTPrintManager sharedInstance].queueId) forKey:kMetricsPrintQueueIdKey];
            [metrics setObject:@(info.copies) forKey:kMetricsPrintQueueCopiesKey];
            [metrics setObject:@{kMPBTPrinterConnected:[[NSNumber numberWithBool:info.connected] stringValue]} forKey:kMPCustomAnalyticsKey];
            [[MPBTPrintManager sharedInstance] addPrintItemToQueue:info.printItem metrics:metrics];
            [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:info.offramp
                                                             printItem:info.printItem
                                                          extendedInfo:metrics];
            self.addToQueueCount++;
        }

    }];
    [queueOperation addDependency:dependency];
    [self.operationQueue addOperation:queueOperation];

    return queueOperation;
}

- (void)queuePrintingCompleteWithConnected:(BOOL)connected drawerOpen:(BOOL)drawerOpen dependency:(NSOperation *)dependency
{
    NSBlockOperation *finishPrinting = [NSBlockOperation blockOperationWithBlock:^{
        PGLogDebug(@"PREVIEW CONTROLLER: OPERATION: FINISH PRINTING");

        MPBTPrinterManagerStatus printerStatus = [MPBTPrintManager sharedInstance].status;
        BOOL isPrinting = printerStatus != MPBTPrinterManagerStatusEmptyQueue && printerStatus != MPBTPrinterManagerStatusIdle;

        if (connected && isPrinting && self.addToQueueCount > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self peekDrawerAnimated:YES];

                self.imageSavedLabel.text = [self numberOfPrintsAddedAndInProgressString:self.addToQueueCount];

                [UIView animateWithDuration:0.5F animations:^{
                    [self showImageSavedView:YES];
                } completion:^(BOOL finished) {
                    [self performSelector:@selector(hideSavedImageView:) withObject:nil afterDelay:2.0];
                }];
            });
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissProgressView];
            if (self.addToQueueCount > 0 && !connected) {
                [self showAddToQueueAlert:self.addToQueueCount withCompletion:nil];
            } else if (connected && !isPrinting) {
                [self resumePrintingWithDrawerOpened:drawerOpen andNumberOfPrintsAddedToQueue:self.addToQueueCount];
            }
        });
    }];

    [finishPrinting addDependency:dependency];
    [self.operationQueue addOperation:finishPrinting];
}

- (NSMutableDictionary *)metricsForInfo:(PGPrintProcessingInfo *)info
{
    NSMutableDictionary *metrics = [[PGAnalyticsManager sharedManager] getMetrics:info.offramp printItem:info.printItem extendedInfo:info.extendedMetrics];
    [metrics setObject:info.origin forKey:kMetricsOrigin];
    return metrics;
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

    [self.carouselView reloadItemAtIndex:index animated:YES];
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
        PGGesturesView *gesturesView = [self createGestureViewWithMedia:selectedMedia[i]];
        gesturesView.delegate = self;
        [self.gesturesViews addObject:gesturesView];

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
    return CGRectMake(0, 0, floorf(self.carouselView.bounds.size.height * kAspectRatio2by3), self.carouselView.bounds.size.height);
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

- (PGGesturesView *) currentGesturesView {
    return  self.gesturesViews[self.carouselView.currentItemIndex];
}

-(HPPRMedia*) currentImageMedia {
    return [self currentGesturesView].media;
}
- (UIImage *)currentEditedImage
{
    PGGesturesView *gesturesView = self.gesturesViews[self.carouselView.currentItemIndex];
    
    gesturesView.editedImage = [gesturesView captureEditedImage];

    return gesturesView.editedImage;
}

- (NSMutableArray<PGGesturesView *> *)gestureViewsSelected
{
    NSMutableArray<PGGesturesView *> *selectedViews = [[NSMutableArray alloc] init];
    for (PGGesturesView *gestureView in self.gesturesViews) {
        if (gestureView.isSelected) {
            [selectedViews addObject:gestureView];
        }
    }

    return selectedViews;
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
            gestureView.editedImage = [gestureView captureEditedImage];
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
