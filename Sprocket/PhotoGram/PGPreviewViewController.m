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
#import "PGGesturesView.h"
#import "PGAppAppearance.h"
#import "UIView+Background.h"
#import "UIColor+Style.h"
#import "UIFont+Style.h"
#import "PGImglyManager.h"
#import "MPPrintManager.h"

#import <MP.h>
#import <MPPrintItemFactory.h>
#import <MPLayoutFactory.h>
#import <MPLayout.h>
#import <MPPrintActivity.h>
#import <MPBTPrintActivity.h>
#import <QuartzCore/QuartzCore.h>

#define kPreviewScreenshotErrorTitle NSLocalizedString(@"Oops!", nil)
#define kPreviewScreenshotErrorMessage NSLocalizedString(@"An error occurred when sharing the item.", nil)
#define kPreviewRetryButtonTitle NSLocalizedString(@"Retry", nil)

static NSInteger const screenshotErrorAlertViewTag = 100;
static CGFloat const kPGPreviewViewControllerFlashTransitionDuration = 0.4F;

@interface PGPreviewViewController() <UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, PGGesturesViewDelegate, IMGLYToolStackControllerDelegate>

@property (strong, nonatomic) MPPrintItem *printItem;
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) PGImglyManager *imglyManager;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (strong, nonatomic) PGGesturesView *imageView;
@property (strong, nonatomic) UIPopoverController *popover;
@property (assign, nonatomic) BOOL needNewImageView;
@property (assign, nonatomic) BOOL didChangeProject;
@property (assign, nonatomic) BOOL selectedNewPhoto;
@end

@implementation PGPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.needNewImageView = NO;
    self.didChangeProject = NO;
    self.selectedNewPhoto = YES;
    
    self.imglyManager = [[PGImglyManager alloc] init];
    
    [self.view layoutIfNeeded];
    
    [PGAnalyticsManager sharedManager].photoSource = self.source;
    [PGAppAppearance addGradientBackgroundToView:self.previewView];
}

- (void)viewWillAppear:(BOOL)animated
{
    static BOOL firstAppearance = YES;
    
    [self.view layoutIfNeeded];
    
    [super viewWillAppear:animated];

    if ([PGCameraManager sharedInstance].isBackgroundCamera) {
        self.transitionEffectView.alpha = 1;
    }
    
    if (self.selectedNewPhoto) {
        if (self.selectedPhoto) {
            self.needNewImageView = YES;
        } else {
            [self showCamera];
        }
    }
    
    if (firstAppearance) {
        firstAppearance = NO;
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
        self.imageContainer.alpha = 0.0F;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    if (self.imageView) {
        [self.imageView adjustContentOffset];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePreviewAndCamera) name:kPGCameraManagerCameraClosed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoTaken) name:kPGCameraManagerPhotoTaken object:nil];
    
    __weak PGPreviewViewController *weakSelf = self;
    [[PGCameraManager sharedInstance] checkCameraPermission:^{
        [[PGCameraManager sharedInstance] addCameraToView:weakSelf.cameraView presentedViewController:self];
        [[PGCameraManager sharedInstance] addCameraButtonsOnView:weakSelf.cameraView];
        [PGCameraManager sharedInstance].isBackgroundCamera = NO;
    } andFailure:^{
        [[PGCameraManager sharedInstance] showCameraPermissionFailedAlert];
    }];
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
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.3F animations:^{
        self.imageContainer.alpha = 1.0F;
        self.imageView.alpha = 1.0F;
        self.transitionEffectView.alpha = 0;
        [self.view setNeedsLayout];
    }];
    
    [[PGCameraManager sharedInstance] startCamera];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ENABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[PGCameraManager sharedInstance] stopCamera];
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
    
    self.imageView.alpha = 0.0F;
    [self.imageContainer addSubview:self.imageView];
    
    [PGAnalyticsManager sharedManager].trackPhotoPosition = YES;
}

- (void)showImgly
{
    IMGLYPhotoEditViewController *photoController = [[IMGLYPhotoEditViewController alloc] initWithPhoto:[self.imageContainer screenshotImage] configuration:self.imglyManager.imglyConfiguration];
    IMGLYToolStackController *toolController = [[IMGLYToolStackController alloc] initWithPhotoEditViewController:photoController configuration:self.imglyManager.imglyConfiguration];
    toolController.delegate = self;
    
    [self presentViewController:toolController animated:NO completion:nil];
}

#pragma mark - IMGLYToolStackControllerDelegate

- (void)toolStackController:(IMGLYToolStackController * _Nonnull)toolStackController didFinishWithImage:(UIImage * _Nonnull)image
{
    [self setSelectedPhoto:image editOfPreviousPhoto:YES];
    self.imageView.image = self.selectedPhoto;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.imageView layoutIfNeeded];
    self.didChangeProject = YES;
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
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPGCameraManagerCameraClosed object:nil];
    }];
}

- (void)hideCamera {
    [UIView animateWithDuration:kPGPreviewViewControllerFlashTransitionDuration / 2 animations:^{
        self.transitionEffectView.alpha = 1;
    } completion:^(BOOL finished) {
        self.previewView.alpha = 1;
        [UIView animateWithDuration:kPGPreviewViewControllerFlashTransitionDuration / 2 animations:^{
            self.transitionEffectView.alpha = 0;
        } completion:nil];
    }];
}

- (void)showCamera {
    __weak PGPreviewViewController *weakSelf = self;
    [[PGCameraManager sharedInstance] checkCameraPermission:^{
        [UIView animateWithDuration:kPGPreviewViewControllerFlashTransitionDuration / 2 animations:^{
            weakSelf.transitionEffectView.alpha = 1;
        } completion:^(BOOL finished) {
            weakSelf.previewView.alpha = 0;
            [UIView animateWithDuration:kPGPreviewViewControllerFlashTransitionDuration / 2 animations:^{
                weakSelf.transitionEffectView.alpha = 0;
            } completion:nil];
            
        }];
    } andFailure:^{
        [[PGCameraManager sharedInstance] showCameraPermissionFailedAlert];
    }];
}

- (void)photoTaken {
    self.selectedPhoto = [PGCameraManager sharedInstance].currentSelectedPhoto;
    
    self.didChangeProject = NO;
    
    [self renderPhoto];
    [self hideCamera];
    
    self.imageContainer.alpha = 1.0F;
    self.imageView.alpha = 1.0F;
    
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

- (IBAction)didTouchUpInsideCameraButton:(id)sender
{
    if (self.didChangeProject) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Dismiss Edits", nil)
                                                                       message:NSLocalizedString(@"Dismiss your project and go to the camera?", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showCamera];
        }];
        [alert addAction:okAction];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self saveToCameraRoll];
            [self showCamera];
        }];
        [alert addAction:saveAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self showCamera];
    }
}

- (IBAction)didTouchUpInsideCloseButton:(id)sender
{
    if (self.didChangeProject) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Dismiss Edits", nil)
                                                                       message:NSLocalizedString(@"Dismiss your project and go to the galleries?", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self closePreviewAndCamera];
        }];
        [alert addAction:okAction];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self saveToCameraRoll];
            [self closePreviewAndCamera];
        }];
        [alert addAction:saveAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        
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
    [[MP sharedInstance] headlessBluetoothPrintFromController:self image:[self.imageContainer screenshotImage] animated:YES completion:nil];
}

- (IBAction)didTouchUpInsideShareButton:(id)sender
{
    PGSaveToCameraRollActivity *saveToCameraRollActivity = [[PGSaveToCameraRollActivity alloc] init];

    MPBTPrintActivity *btPrintActivity = [[MPBTPrintActivity alloc] init];
    btPrintActivity.image = [self.imageContainer screenshotImage];
    btPrintActivity.vc = self;
    
    [self presentActivityViewControllerWithActivities:@[btPrintActivity, saveToCameraRollActivity]];

}

- (void)saveToCameraRoll
{
    UIImage *image = [self.imageContainer screenshotImage];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
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
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:self.printItem.activityItems applicationActivities:applicationActivities];
        
        [activityViewController setValue:NSLocalizedString(@"My HP Snapshot", nil) forKey:@"subject"];
        
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
                offramp = [MPPrintManager printNowOfframp];
            }
            
            if (!offramp) {
                PGLogError(@"Missing offramp key for share activity");
            }
            
            if (completed) {
                [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offramp printItem:weakSelf.printItem exendedInfo:extendedMetrics];
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

#pragma mark - UIPopoverPresentationControllerDelegate

// NOTE: The implementation of this delegate with the default value is a workaround to compensate an error in the new popover presentation controller of the SDK 8. This fix corrects the case where if the user keep tapping repeatedly the share button in an iPad iOS 8, the app goes back to the first screen.
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}

@end
