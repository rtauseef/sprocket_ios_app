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

#import <MP.h>
#import <HPPR.h>
#import <MPPrintItemFactory.h>
#import <MPLayoutFactory.h>
#import <MPLayout.h>
#import <MPPrintActivity.h>
#import <MPBTPrintActivity.h>
#import <HPPRCameraRollLoginProvider.h>
#import <QuartzCore/QuartzCore.h>
#import <Crashlytics/Crashlytics.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define kPreviewScreenshotErrorTitle NSLocalizedString(@"Oops!", nil)
#define kPreviewScreenshotErrorMessage NSLocalizedString(@"An error occurred when sharing the item.", nil)
#define kPreviewRetryButtonTitle NSLocalizedString(@"Retry", nil)

static NSInteger const screenshotErrorAlertViewTag = 100;
static NSUInteger const kPGPreviewViewControllerPrinterConnectivityCheckInterval = 1;
static NSString * const kPGPreviewViewControllerNumPrintsKey = @"kPGPreviewViewControllerNumPrintsKey";
static CGFloat const kPGPreviewViewControllerCarouselPhotoSizeMultiplier = 1.8;
static NSInteger const kNumPrintsBeforeInterstitialMessage = 2;
static CGFloat kAspectRatio2by3 = 0.66666666667;

@interface PGPreviewViewController() <UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, PGGesturesViewDelegate, IMGLYToolStackControllerDelegate>

@property (strong, nonatomic) MPPrintItem *printItem;
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) PGImglyManager *imglyManager;
@property (strong, nonatomic) NSTimer *sprocketConnectivityTimer;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (strong, nonatomic) IBOutlet iCarousel *carouselView;

@property (strong, nonatomic) PGGesturesView *imageView;
@property (strong, nonatomic) UIPopoverController *popover;
@property (assign, nonatomic) BOOL didChangeProject;
@property (weak, nonatomic) IBOutlet UIView *imageSavedView;
@property (weak, nonatomic) IBOutlet UIButton *printButton;
@property (strong, nonatomic) NSString *currentOfframp;

@property (nonatomic, strong) NSMutableArray<PGGesturesView *> *gesturesViews;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSelectedPhotos;

@end

@implementation PGPreviewViewController

+ (void)presentPreviewPhotoFrom:(UIViewController *)currentViewController andSource:(NSString *)source animated:(BOOL)animated
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.source = source;
    if (animated) {
        [previewViewController setModalPresentationStyle:UIModalPresentationOverFullScreen];
        [previewViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    }
    
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
    
    self.imglyManager = [[PGImglyManager alloc] init];
    
    if ([PGPhotoSelection sharedInstance].hasMultiplePhotos) {
        self.bottomViewHeight.constant *= kPGPreviewViewControllerCarouselPhotoSizeMultiplier;
    } else {
        [[PGAnalyticsManager sharedManager] trackSelectPhoto:self.source];
    }
    
    [self.view layoutIfNeeded];
    
    [self configureCarousel];
    
    [self.view layoutIfNeeded];
    
    [PGAnalyticsManager sharedManager].photoSource = self.source;

    [PGAppAppearance addGradientBackgroundToView:self.previewView];
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

    self.numberOfSelectedPhotos.hidden = ![PGPhotoSelection sharedInstance].hasMultiplePhotos;;
    self.imageContainer.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // hidding imageSavedView on the storyboard to avoid seeing the bar when opening preview screen.
    self.imageSavedView.hidden = NO;
    
    [self.carouselView reloadData];
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

- (void)configureCarousel
{
    self.carouselView.type = iCarouselTypeLinear;
    [self.carouselView setBounceDistance:0.3];
    
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
        
        if (self.gesturesViews[i].media.asset) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self.gesturesViews[i].media requestImageWithCompletion:^(UIImage *image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.gesturesViews[i] setImage:image];
                        [weakSelf.carouselView reloadItemAtIndex:i animated:NO];
                    });
                }];
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[HPPRCacheService sharedInstance] imageForUrl:weakSelf.gesturesViews[i].media.standardUrl asThumbnail:NO withCompletion:^(UIImage *image, NSString *url, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.gesturesViews[i] setImage:image];
                        [weakSelf.carouselView reloadItemAtIndex:i animated:NO];
                    });
                }];
            });
        }
    }
}

- (void)showImgly
{
    UIImage *photoToEdit = nil;
    photoToEdit = [self.carouselView.currentItemView screenshotImage];
    
    IMGLYConfiguration *configuration = [self.imglyManager imglyConfiguration];
    IMGLYPhotoEditViewController *photoController = [[IMGLYPhotoEditViewController alloc] initWithPhoto:photoToEdit configuration:configuration];
    IMGLYToolStackController *toolController = [[IMGLYToolStackController alloc] initWithPhotoEditViewController:photoController configuration:configuration];
    toolController.delegate = self;
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

#pragma mark - IMGLYToolStackControllerDelegate

- (void)toolStackController:(IMGLYToolStackController * _Nonnull)toolStackController didFinishWithImage:(UIImage * _Nonnull)image
{
    [self.gesturesViews[self.carouselView.currentItemIndex] setImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];

    self.didChangeProject = YES;
    [self.carouselView reloadItemAtIndex:self.carouselView.currentItemIndex animated:YES];
}

- (void)toolStackControllerDidCancel:(IMGLYToolStackController * _Nonnull)toolStackController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toolStackControllerDidFail:(IMGLYToolStackController * _Nonnull)toolStackController
{
    MPLogError(@"toolStackControllerDidFail:%@", toolStackController);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Camera Handlers

- (void)closePreviewAndCamera {
    if ([self.source isEqualToString:[PGPreviewViewController cameraSource]]) {
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
    [[PGPhotoSelection sharedInstance] savePhotosByGesturesView:self.gesturesViews completion:^(BOOL success) {
        if (success) {
            [[PGAnalyticsManager sharedManager] trackSaveProjectActivity:kEventSaveProjectPreview];
            
            [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:NSStringFromClass([PGSaveToCameraRollActivity class])
                                                             printItem:self.printItem
                                                           exendedInfo:[self extendedMetrics]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5F animations:^{
                    [self showImageSavedView:YES];
                } completion:^(BOOL finished) {
                    [self performSelector:@selector(hideSavedImageView:) withObject:nil afterDelay:1.0];
                }];
            });
        }
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

            [[PGPhotoSelection sharedInstance] savePhotosByGesturesView:self.gesturesViews completion:^(BOOL success) {
                if (success) {
                    [self closePreviewAndCamera];
                    [[PGAnalyticsManager sharedManager] trackDismissEditActivity:kEventDismissEditSaveAction
                                                                          source:kEventDismissEditCloseLabel];

                    [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:NSStringFromClass([PGSaveToCameraRollActivity class])
                                                                     printItem:weakSelf.printItem
                                                                   exendedInfo:[weakSelf extendedMetrics]];
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
    [self showImgly];
}

- (IBAction)didTouchUpInsidePrinterButton:(id)sender
{
    self.currentOfframp = [MPPrintManager directPrintOfframp];
    [[MP sharedInstance] headlessBluetoothPrintFromController:self image:[self.imageContainer screenshotImage] animated:YES printCompletion:nil];
    [[PGAnalyticsManager sharedManager] trackPrintRequest:kEventPrintButtonLabel];
}

- (IBAction)didTouchUpInsideShareButton:(id)sender
{
    UIImage *image = [self.imageContainer screenshotImage];
    PGSaveToCameraRollActivity *saveToCameraRollActivity = [[PGSaveToCameraRollActivity alloc] init];
    saveToCameraRollActivity.image = image;
    
    MPBTPrintActivity *btPrintActivity = [[MPBTPrintActivity alloc] init];
    btPrintActivity.image = image;
    btPrintActivity.vc = self;
    
    [[MP sharedInstance] closeAccessorySession];
    
    [self presentActivityViewControllerWithActivities:@[btPrintActivity, saveToCameraRollActivity]];

}


#pragma mark - Print preparation

- (MPPaper *)paper
{
    return [MP sharedInstance].defaultPaper;
}

- (MPLayout *)layout
{
    return [MPLayoutFactory layoutWithType:[MPLayoutFill layoutType]];
}

- (NSDictionary *)extendedMetrics
{
    return @{
             kMetricsTypePhotoSourceKey:[[PGAnalyticsManager sharedManager] photoSourceMetrics],
             kMPMetricsEmbellishmentKey:[self.imglyManager analyticsString]
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
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.carouselView.currentItemView.screenshotImage] applicationActivities:applicationActivities];
        
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
            NSDictionary *extendedMetrics = [weakSelf extendedMetrics];
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
                    [[PGAnalyticsManager sharedManager] trackShareActivity:offramp withResult:kEventResultSuccess];
                    [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offramp printItem:weakSelf.printItem exendedInfo:extendedMetrics];
                } else {
                    self.currentOfframp = offramp;
                }
            } else {
                if (activityType) {
                    [[PGAnalyticsManager sharedManager] trackShareActivity:offramp withResult:kEventResultCancel];
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
        
        [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:self.currentOfframp printItem:self.printItem exendedInfo:self.extendedMetrics];
        
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

#pragma mark - iCarousel methods

- (PGGesturesView *)createGestureViewWithMedia:(HPPRMedia *)media
{
    PGGesturesView *gestureView = [[PGGesturesView alloc] initWithFrame:CGRectMake(0, 0, self.carouselView.bounds.size.height * kAspectRatio2by3, self.carouselView.bounds.size.height)];
    gestureView.media = media;
    gestureView.doubleTapBehavior = PGGesturesDoubleTapReset;
    
    if ([PGPhotoSelection sharedInstance].hasMultiplePhotos) {
        gestureView.isMultiSelectImage = YES;
        gestureView.allowGestures = NO;
    } else {
        gestureView.isMultiSelectImage = NO;
    }
    
    gestureView.isSelected = YES;
    
    if (media.image) {
        UIImage *finalImage = media.image;
        
        if (media.image.size.width > media.image.size.height) {
            finalImage = [[UIImage alloc] initWithCGImage: media.image.CGImage
                                                    scale: 1.0
                                              orientation: UIImageOrientationRight];
        }
        
        gestureView.image = finalImage;
        
        [self.carouselView setNeedsLayout];
    }
    
    return gestureView;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.gesturesViews count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    PGGesturesView *gestureView = self.gesturesViews[index];
    
    if (gestureView.media.image) {
        UIImage *finalImage = gestureView.media.image;
        
        if (gestureView.media.image.size.width > gestureView.media.image.size.height) {
            finalImage = [[UIImage alloc] initWithCGImage: gestureView.media.image.CGImage
                                                    scale: 1.0
                                              orientation: UIImageOrientationRight];
        }
        
        [gestureView setImage:finalImage];

        [carousel setNeedsLayout];
    }
    
    return gestureView;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    if ([PGPhotoSelection sharedInstance].hasMultiplePhotos && (carousel.currentItemIndex != -1)) {
        self.numberOfSelectedPhotos.text = [NSString stringWithFormat:NSLocalizedString(@"%ld of %ld", nil), (carousel.currentItemIndex + 1), (long)self.gesturesViews.count];
        self.editButton.hidden = !self.gesturesViews[carousel.currentItemIndex].isSelected;
        
        self.printItem = [MPPrintItemFactory printItemWithAsset:[self.carouselView.currentItemView screenshotImage]];
        self.printItem.layout = [self layout];
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap) {
        return self.gesturesViews.count > 2;
    }
    
    if (option == iCarouselOptionSpacing) {
        return value + (10.0f / (self.carouselView.bounds.size.height * kAspectRatio2by3));
    }
    
    return value;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    self.gesturesViews[carousel.currentItemIndex].isSelected = !self.gesturesViews[carousel.currentItemIndex].isSelected;
    self.editButton.hidden = !self.gesturesViews[carousel.currentItemIndex].isSelected;
    
    [carousel reloadData];
}

@end
