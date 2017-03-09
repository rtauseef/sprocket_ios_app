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
@property (strong, nonatomic) UIImage *originalImage;
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
@property (assign, nonatomic) BOOL needNewImageView;
@property (assign, nonatomic) BOOL didChangeProject;
@property (assign, nonatomic) BOOL selectedNewPhoto;
@property (assign, nonatomic) BOOL firstAppearance;
@property (weak, nonatomic) IBOutlet UIView *imageSavedView;
@property (weak, nonatomic) IBOutlet UIButton *printButton;
@property (strong, nonatomic) NSString *currentOfframp;

@property (nonatomic, strong) NSMutableArray<HPPRMedia *> *items;
@property (nonatomic, strong) NSMutableArray *selectedItems;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSelectedPhotos;

@end

@implementation PGPreviewViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.trackableScreenName = @"Preview Screen";

    self.needNewImageView = NO;
    self.didChangeProject = NO;
    self.selectedNewPhoto = YES;
    self.firstAppearance = YES;
    
    self.editButton.titleLabel.font = [UIFont HPSimplifiedLightFontWithSize:20];
    self.editButton.titleLabel.tintColor = [UIColor whiteColor];
    
    self.imglyManager = [[PGImglyManager alloc] init];
    
    if ([PGPhotoSelection sharedInstance].isInSelectionMode) {
        self.bottomViewHeight.constant *= kPGPreviewViewControllerCarouselPhotoSizeMultiplier;
        [self configureCarousel];
    }
    
    [self.view layoutIfNeeded];
    
    [PGAnalyticsManager sharedManager].photoSource = self.source;

    if (![[PGPhotoSelection sharedInstance] isInSelectionMode]) {
        [[PGAnalyticsManager sharedManager] trackSelectPhoto:self.source];
    }

    [PGAppAppearance addGradientBackgroundToView:self.previewView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view layoutIfNeeded];
    [super viewWillAppear:animated];
    
    if (self.selectedNewPhoto) {
        if (self.selectedPhoto || [PGPhotoSelection sharedInstance].isInSelectionMode) {
            self.needNewImageView = YES;
        } else {
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
    }
    
    if (self.firstAppearance) {
        self.firstAppearance = NO;
        CGRect frame = self.imageContainer.frame;
        
        CGFloat aspectRatioWidth = [self paper].width;
        CGFloat aspectRatioHeight = [self paper].height;
        
        CGFloat desiredWidth = self.imageContainer.frame.size.width;
        CGFloat desiredHeight = (aspectRatioHeight / aspectRatioWidth) * self.imageContainer.frame.size.width;
        if (desiredHeight > self.previewView.frame.size.height - (self.topView.frame.size.height + self.bottomView.frame.size.height)) {
            desiredHeight = self.imageContainer.frame.size.height;
            desiredWidth = (aspectRatioWidth / aspectRatioHeight) * desiredHeight;
        }
        frame.size.height = desiredHeight;
        frame.size.width = desiredWidth;
        
        self.imageContainer.frame = frame;
        
        [self.view layoutIfNeeded];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    if (self.imageView) {
        // Don't let the adjustContentOffset function effect our didChangeProject value
        BOOL originalChangProjectVal = self.didChangeProject;
        [self.imageView adjustContentOffset];
        self.didChangeProject = originalChangProjectVal;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePreviewAndCamera) name:kPGCameraManagerCameraClosed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoTaken) name:kPGCameraManagerPhotoTaken object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintJobCompletedNotification:) name:kMPBTPrintJobCompletedNotification object:nil];
    
    [self checkSprocketPrinterConnectivity:nil];
    
    self.sprocketConnectivityTimer = [NSTimer scheduledTimerWithTimeInterval:kPGPreviewViewControllerPrinterConnectivityCheckInterval target:self selector:@selector(checkSprocketPrinterConnectivity:) userInfo:nil repeats:YES];
    
    BOOL isInSelectionMode = [PGPhotoSelection sharedInstance].isInSelectionMode;
    
    self.carouselView.hidden = !isInSelectionMode;
    self.numberOfSelectedPhotos.hidden = !isInSelectionMode;
    self.imageContainer.hidden = isInSelectionMode;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //  The code below produces an imageView in the wrong location inside of viewWillAppear
    //   ... need to do it here...
    if (self.needNewImageView) {
        self.needNewImageView = NO;
        [self renderPhoto];
    }
    
    [self showPhoto];
    
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

- (void)setSelectedPhoto:(UIImage *)selectedPhoto editOfPreviousPhoto:(BOOL)edited
{
    self.selectedNewPhoto = YES;
    
    self.originalImage = selectedPhoto;
    UIImage *finalImage = self.originalImage;
    
    if (selectedPhoto.size.width > selectedPhoto.size.height) {
        finalImage = [[UIImage alloc] initWithCGImage: selectedPhoto.CGImage
                                                scale: 1.0
                                          orientation: UIImageOrientationRight];
    }
    
    _selectedPhoto = finalImage;
    
    if (!edited) {
        self.printItem = [MPPrintItemFactory printItemWithAsset:_selectedPhoto];
        self.printItem.layout = [self layout];
    }
}

- (void)configureCarousel
{
    self.carouselView.type = iCarouselTypeLinear;
    [self.carouselView setBounceDistance:0.3];
    self.carouselView.pagingEnabled = YES;
    
    self.items = [NSMutableArray arrayWithArray:[PGPhotoSelection sharedInstance].selectedMedia];
    self.selectedItems = [NSMutableArray array];
    self.selectedPhoto = self.items[0].thumbnailImage;
    
    __weak typeof(self) weakSelf = self;
    for (int i = 0; i < self.items.count; i++) {
        [_selectedItems addObject:[NSNumber numberWithBool:YES]];
        if (self.items[i].asset) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [weakSelf.items[i] requestImageWithCompletion:^(UIImage *image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.items[i].image = image;
                        [weakSelf.carouselView reloadItemAtIndex:i animated:NO];
                    });
                }];
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[HPPRCacheService sharedInstance] imageForUrl:weakSelf.items[i].standardUrl asThumbnail:NO withCompletion:^(UIImage *image, NSString *url, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.items[i].image = image;
                        [weakSelf.carouselView reloadItemAtIndex:i animated:NO];
                    });
                }];
            });
        }
    }
}

- (void)setSelectedPhoto:(UIImage *)selectedPhoto
{
    [self setSelectedPhoto:selectedPhoto editOfPreviousPhoto:NO];
}

- (void)renderPhoto {
    if (nil != self.imageView) {
        [self.imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    
    [PGAnalyticsManager sharedManager].trackPhotoPosition = NO;
    [PGAnalyticsManager sharedManager].photoPanEdited = NO;
    [PGAnalyticsManager sharedManager].photoZoomEdited = NO;
    [PGAnalyticsManager sharedManager].photoRotationEdited = NO;
    
    self.imageView = [[PGGesturesView alloc] initWithFrame:self.imageContainer.bounds];
    self.imageView.image = self.selectedPhoto;
    self.imageView.doubleTapBehavior = PGGesturesDoubleTapReset;
    self.imageView.delegate = self;

    [self.imageContainer addSubview:self.imageView];
    
    [PGAnalyticsManager sharedManager].trackPhotoPosition = YES;
}

- (void)showImgly
{
    UIImage *photoToEdit = nil;
    if ([PGPhotoSelection sharedInstance].isInSelectionMode) {
        photoToEdit = self.items[self.carouselView.currentItemIndex].image;
    } else {
        photoToEdit = [self.imageContainer screenshotImage];
    }
    
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

- (void)showPhoto
{
    if (self.selectedNewPhoto) {
        self.imageView.alpha = 0.0F;
    }
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5F animations:^{
        self.imageView.alpha = 1.0F;
        [self.view layoutIfNeeded];
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
    self.imageView.alpha = 0.0f;
    [self setSelectedPhoto:image editOfPreviousPhoto:YES];
    self.imageView.image = self.selectedPhoto;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.imageView layoutIfNeeded];
    self.didChangeProject = YES;
    [self showPhoto];
}

- (void)toolStackControllerDidCancel:(IMGLYToolStackController * _Nonnull)toolStackController
{
    self.selectedNewPhoto = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toolStackControllerDidFail:(IMGLYToolStackController * _Nonnull)toolStackController
{
    MPLogError(@"toolStackControllerDidFail:%@", toolStackController);
    self.selectedNewPhoto = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Camera Handlers

- (void)closePreviewAndCamera {
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
    self.selectedPhoto = [PGCameraManager sharedInstance].currentSelectedPhoto;
    self.didChangeProject = NO;
    
    [self renderPhoto];
    [self hideCamera];
    [self showPhoto];
    
    self.source = [PGPreviewViewController cameraSource];
    [PGAnalyticsManager sharedManager].photoSource = self.source;
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


#pragma mark - Button Handlers

- (IBAction)didTouchUpInsideDownloadButton:(id)sender
{
    UIImage *image = [self.imageContainer screenshotImage];

    [[PGCameraManager sharedInstance] saveImage:image completion:^(BOOL success) {
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
            UIImage *image = [self.imageContainer screenshotImage];

            [[PGCameraManager sharedInstance] saveImage:image completion:^(BOOL success) {
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
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.selectedPhoto] applicationActivities:applicationActivities];
        
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

// NOTE: The implementation of this delegate with the default value is a workaround to compensate an error in the new popover presentation controller of the SDK 8. This fix corrects the case where if the user keep tapping repeatedly the share button in an iPad iOS 8, the app goes back to the first screen.
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}

#pragma mark - iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    HPPRMedia *media = (HPPRMedia *)self.items[index];
    PGGesturesView *gestureView = (PGGesturesView *)view;
    
    if (view == nil) {
        gestureView = [[PGGesturesView alloc] initWithFrame:CGRectMake(0, 0, self.carouselView.bounds.size.height * kAspectRatio2by3, self.carouselView.bounds.size.height)];
        
        gestureView.doubleTapBehavior = PGGesturesDoubleTapReset;
        gestureView.isMultiSelectImage = YES;
        
        [gestureView disableGestures];
    }
    
    if (media.image) {
        UIImage *finalImage = media.image;
        
        if (media.image.size.width > media.image.size.height) {
            finalImage = [[UIImage alloc] initWithCGImage: media.image.CGImage
                                                    scale: 1.0
                                              orientation: UIImageOrientationRight];
        }
        
        gestureView.image = finalImage;
        [gestureView adjustContentOffset];
        
        [carousel setNeedsLayout];
    }
    
    if (self.selectedItems) {
        gestureView.isSelected = ((NSNumber *) self.selectedItems[index]).boolValue;
    }
    
    return gestureView;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    if ([PGPhotoSelection sharedInstance].isInSelectionMode && (carousel.currentItemIndex != -1)) {
        self.numberOfSelectedPhotos.text = [NSString stringWithFormat:NSLocalizedString(@"%ld of %ld", nil), (carousel.currentItemIndex + 1), (long)self.items.count];
        self.editButton.hidden = !((NSNumber *)self.selectedItems[carousel.currentItemIndex]).boolValue;
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap) {
        return self.items.count > 2;
    }
    
    if (option == iCarouselOptionSpacing) {
        return value + (10.0f / (self.carouselView.bounds.size.height * kAspectRatio2by3));
    }
    
    return value;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSNumber *selectedValue = (NSNumber *) self.selectedItems[index];
    selectedValue = [NSNumber numberWithBool:!selectedValue.boolValue];
    
    self.selectedItems[index] = selectedValue;
    self.editButton.hidden = !selectedValue;
    
    [carousel reloadData];
}

@end
