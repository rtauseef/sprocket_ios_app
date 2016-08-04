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
#import "PGSelectTemplateViewController.h"
#import "PGGesturesView.h"
#import "PGAppAppearance.h"
#import "UIView+Background.h"
#import "UIColor+Style.h"
#import "UIFont+Style.h"

#import <imglyKit/imglyKit-Swift.h>
#import <MP.h>
#import <MPPrintItemFactory.h>
#import <MPLayoutFactory.h>
#import <MPLayout.h>
#import <MPPrintActivity.h>
#import <MPPrintLaterActivity.h>
#import <MPBTPrintActivity.h>
#import <QuartzCore/QuartzCore.h>

#define kPreviewScreenshotErrorTitle NSLocalizedString(@"Oops!", nil)
#define kPreviewScreenshotErrorMessage NSLocalizedString(@"An error occurred when sharing the item.", nil)
#define kPreviewRetryButtonTitle NSLocalizedString(@"Retry", nil)

static NSInteger const screenshotErrorAlertViewTag = 100;
static CGFloat const kPGPreviewViewControllerFlashTransitionDuration = 0.4F;

@interface PGPreviewViewController() <MPPrintDataSource, UIPopoverPresentationControllerDelegate, MPPrintDelegate, UIGestureRecognizerDelegate, PGGesturesViewDelegate, IMGLYToolStackControllerDelegate, IMGLYStickersDataSourceProtocol>

@property (strong, nonatomic) MPPrintItem *printItem;
@property (strong, nonatomic) MPPrintLaterJob *printLaterJob;
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) IBOutlet UIView *cameraView;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (strong, nonatomic) PGGesturesView *imageView;
@property (strong, nonatomic) UIPopoverController *popover;
@property (assign, nonatomic) BOOL needNewImageView;
@property (assign, nonatomic) BOOL didChangeProject;

@end

@implementation PGPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.printItem = nil;
    self.needNewImageView = NO;
    self.didChangeProject = NO;
    
    [self.view layoutIfNeeded];
    
    [PGAppAppearance addGradientBackgroundToView:self.previewView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view layoutIfNeeded];
    
    [super viewWillAppear:animated];

    if ([PGCameraManager sharedInstance].isBackgroundCamera) {
        self.transitionEffectView.alpha = 1;
    }
    
    if (nil == self.printItem) {
        if (self.selectedPhoto) {
            self.printItem = [MPPrintItemFactory printItemWithAsset:self.selectedPhoto];
            self.printItem.layout = [self layout];
            self.needNewImageView = YES;
        } else {
            [self showCamera];
        }
        
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

- (void)setSelectedPhoto:(UIImage *)selectedPhoto
{
    self.printItem = nil;

    self.originalImage = selectedPhoto;
    UIImage *finalImage = self.originalImage;
    
    if (selectedPhoto.size.width > selectedPhoto.size.height) {
        finalImage = [[UIImage alloc] initWithCGImage: selectedPhoto.CGImage
                                                scale: 1.0
                                          orientation: UIImageOrientationRight];
    }
    
    _selectedPhoto = finalImage;
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
    IMGLYPhotoEditViewController *photoController = [[IMGLYPhotoEditViewController alloc] initWithPhoto:self.imageView.image configuration:[self imglyConfiguration]];
    IMGLYToolStackController *toolController = [[IMGLYToolStackController alloc] initWithPhotoEditViewController:photoController configuration:[self imglyConfiguration]];
    toolController.delegate = self;
    
    [self presentViewController:toolController animated:NO completion:nil];
}

#pragma mark - IMGLY Stickers

- (void)stickerCount:(void (^ _Nonnull)(NSInteger, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        completionBlock(1, nil);
    }
}

- (void)thumbnailAndLabelAtIndex:(NSInteger)index completionBlock:(void (^ _Nonnull)(UIImage * _Nullable, NSString * _Nullable, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        completionBlock([UIImage imageNamed:@"stickerHearts"], nil, nil);
    }
}

- (void)stickerAtIndex:(NSInteger)index completionBlock:(void (^ _Nonnull)(IMGLYSticker * _Nullable, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        IMGLYSticker *sticker = [[IMGLYSticker alloc] initWithImage:[UIImage imageNamed:@"stickerHearts"] thumbnail:[UIImage imageNamed:@"stickerHearts"] accessibilityText:nil];
        completionBlock(sticker, nil);
    }
}

#pragma mark - IMGLY Configuration

- (IMGLYConfiguration *)imglyConfiguration
{
    IMGLYConfiguration *configuration = [[IMGLYConfiguration alloc] initWithBuilder:^(IMGLYConfigurationBuilder * _Nonnull builder) {
        
        builder.contextMenuBackgroundColor = [UIColor HPGrayColor];
        
        [builder configureToolStackController:^(IMGLYToolStackControllerOptionsBuilder * _Nonnull stackBuilder) {
            stackBuilder.mainToolbarBackgroundColor = [UIColor HPGrayColor];
            stackBuilder.secondaryToolbarBackgroundColor = [UIColor clearColor];
        }];
        
        [builder configurePhotoEditorViewController:^(IMGLYPhotoEditViewControllerOptionsBuilder * _Nonnull photoEditorBuilder) {
            photoEditorBuilder.allowedPhotoEditorActionsAsNSNumbers = @[
                                                                        [NSNumber numberWithInteger:PhotoEditorActionFilter],
                                                                        [NSNumber numberWithInteger:PhotoEditorActionFrame],
                                                                        [NSNumber numberWithInteger:PhotoEditorActionSticker],
                                                                        [NSNumber numberWithInteger:PhotoEditorActionText],
                                                                        [NSNumber numberWithInteger:PhotoEditorActionCrop]
                                                                        ];
            photoEditorBuilder.frameScaleMode = UIViewContentModeScaleToFill;
            photoEditorBuilder.backgroundColor = [UIColor HPGrayColor];
            photoEditorBuilder.allowsPreviewImageZoom = NO;
            
            [photoEditorBuilder setActionButtonConfigurationClosure:^(IMGLYIconCaptionCollectionViewCell * _Nonnull cell, enum PhotoEditorAction action) {
                switch (action) {
                    case PhotoEditorActionFilter:
                        cell.imageView.image = [UIImage imageNamed:@"editFilters"];
                        cell.accessibilityIdentifier = @"editFilters";
                        break;
                    case PhotoEditorActionFrame:
                        cell.imageView.image = [UIImage imageNamed:@"editFrame"];
                        cell.accessibilityIdentifier = @"editFrame";
                        break;
                    case PhotoEditorActionSticker:
                        cell.imageView.image = [UIImage imageNamed:@"editSticker"];
                        cell.accessibilityIdentifier = @"editSticker";
                        break;
                    case PhotoEditorActionText:
                        cell.imageView.image = [UIImage imageNamed:@"editText"];
                        cell.accessibilityIdentifier = @"editText";
                        break;
                    case PhotoEditorActionCrop:
                        cell.imageView.image = [UIImage imageNamed:@"editCrop"];
                        cell.accessibilityIdentifier = @"editCrop";
                        break;
                    default:
                        break;
                }
                
                cell.captionLabel.text = nil;
            }];
        }];
        
        [builder configureStickerToolController:^(IMGLYStickerToolControllerOptionsBuilder * _Nonnull stickerBuilder) {
            stickerBuilder.stickersDataSource = self;
        }];
        
        [builder configureCropToolController:^(IMGLYCropToolControllerOptionsBuilder * _Nonnull cropToolBuilder) {
            IMGLYCropRatio *cropRatio2x3 = [[IMGLYCropRatio alloc] initWithRatio:[NSNumber numberWithFloat:2.0/3.0] title:@"2:3" accessibilityLabel:@"2:3 crop ratio" icon:[UIImage imageNamed:@"crop.2x3.png"]];
            IMGLYCropRatio *cropRatio3x2 = [[IMGLYCropRatio alloc] initWithRatio:[NSNumber numberWithFloat:3.0/2.0] title:@"3:2" accessibilityLabel:@"3:2 crop ratio" icon:[UIImage imageNamed:@"crop.3x2.png"]];
            cropToolBuilder.allowedCropRatios = @[
                                                  cropRatio2x3,
                                                  cropRatio3x2 ];
        }];
    }];
    
    return configuration;
}

#pragma mark - IMGLYToolStackControllerDelegate

- (void)toolStackController:(IMGLYToolStackController * _Nonnull)toolStackController didFinishWithImage:(UIImage * _Nonnull)image
{
    NSLog(@"IMAGE:  %@", image);
    self.imageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.imageView layoutIfNeeded];
}

- (void)toolStackControllerDidCancel:(IMGLYToolStackController * _Nonnull)toolStackController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", nil)
                                                                   message:NSLocalizedString(@"Do you want to return to preview and dismiss your edits?", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:noAction];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:yesAction];
    
    [toolStackController presentViewController:alert animated:YES completion:nil];
}

- (void)toolStackControllerDidFail:(IMGLYToolStackController * _Nonnull)toolStackController
{
    NSLog(@"FAIL");
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
    self.media = [PGCameraManager sharedInstance].currentMedia;
    self.selectedPhoto = [PGCameraManager sharedInstance].currentSelectedPhoto;
    self.printItem = [MPPrintItemFactory printItemWithAsset:self.selectedPhoto];
    self.printItem.layout = [self layout];
    
    self.didChangeProject = NO;
    
    [self renderPhoto];
    [self hideCamera];
    
    self.imageContainer.alpha = 1.0F;
    self.imageView.alpha = 1.0F;
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", nil)
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", nil)
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
    
    return;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGSelectTemplateViewController *templateViewController = (PGSelectTemplateViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGSelectTemplateViewController"];
    
    templateViewController.source = self.source;
    templateViewController.selectedPhoto = self.originalImage;
    templateViewController.media = self.media;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:templateViewController];
    [self presentViewController:navController animated:YES completion:nil];
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
//           kMetricsTypeLocationKey:[self locationMetrics],
             kMetricsTypePhotoSourceKey:[[PGAnalyticsManager sharedManager] photoSourceMetrics],
//           kMetricsTypePhotoPositionKey:[[PGAnalyticsManager sharedManager] photoPositionMetricsWithOffset:self.svgLoader.offset zoom:self.svgLoader.zoom angle:self.svgLoader.angle]
             };
}

- (void)printLaterItemsWithCompletion:(void (^)(NSDictionary *result))completion
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:1];
    
    MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:self.selectedPhoto];
    printItem.layout = [self layout];
    
    [result setValue:printItem forKey:[self paper].sizeTitle];
    
    if (completion) {
        completion(result);
    }
}

- (void)preparePrintJobWithCompletion:(void(^)(void))completion
{
    NSString *printLaterJobNextAvailableId = [[MP sharedInstance] nextPrintJobId];
    self.printLaterJob = [[MPPrintLaterJob alloc] init];
    self.printLaterJob.id = printLaterJobNextAvailableId;
    self.printLaterJob.date = [NSDate date];
    self.printLaterJob.extra = [self extendedMetrics];
    [self printLaterItemsWithCompletion:^(NSDictionary *result) {
        self.printLaterJob.printItems = result;
        if (completion) {
            completion();
        }
    }];
}

- (void)shareItem
{
    PGSaveToCameraRollActivity *saveToCameraRollActivity = [[PGSaveToCameraRollActivity alloc] init];
    
    MPPrintActivity *printActivity = [[MPPrintActivity alloc] init];
    printActivity.dataSource = self;
    
    if (IS_OS_8_OR_LATER && ![[MP sharedInstance] isWifiConnected]) {
        MPPrintLaterActivity *printLaterActivity = [[MPPrintLaterActivity alloc] init];
        [self preparePrintJobWithCompletion:^{
            printLaterActivity.printLaterJob = self.printLaterJob;
            [self presentActivityViewControllerWithActivities:@[printLaterActivity, saveToCameraRollActivity]];
        }];
    } else {
        MPPrintActivity *printActivity = [[MPPrintActivity alloc] init];
        printActivity.dataSource = self;
        [self presentActivityViewControllerWithActivities:@[printActivity, saveToCameraRollActivity]];
    }
}

- (void)presentActivityViewControllerWithActivities:(NSArray *)applicationActivities
{
    if (nil == self.printItem) {
        // NOTE. We couldn't recreate this situation, but there is a crash reported in crashlytics indicating that this has happened: Crash 1.3(995) #81
        if (NSClassFromString(@"UIAlertController") != nil) {
            UIAlertController *errorScreenshotController = [UIAlertController alertControllerWithTitle:kPreviewScreenshotErrorTitle message:kPreviewScreenshotErrorMessage preferredStyle:UIAlertControllerStyleAlert];
            [errorScreenshotController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
            [errorScreenshotController addAction:[UIAlertAction actionWithTitle:kPreviewRetryButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self shareItem];
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
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
            
            BOOL printActivity = [activityType isEqualToString: NSStringFromClass([MPPrintActivity class])];
            BOOL printLaterActivity = [activityType isEqualToString: NSStringFromClass([MPPrintLaterActivity class])];
            
            NSString *offramp = activityType;
            NSDictionary *extendedMetrics = [weakSelf extendedMetrics];
            if (printActivity) {
                offramp = [weakSelf.printItem.extra objectForKey:kMetricsOfframpKey];
            } else if (printLaterActivity) {
                offramp = [weakSelf.printLaterJob.extra objectForKey:kMetricsOfframpKey];
                extendedMetrics = self.printLaterJob.extra;
            }
            
            if (!offramp) {
                PGLogError(@"Missing offramp key for share activity");
            }
            
            if (completed) {
                [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offramp printItem:weakSelf.printItem exendedInfo:extendedMetrics];
                if (printLaterActivity) {
                    [[MP sharedInstance] presentPrintQueueFromController:weakSelf animated:YES completion:nil];
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

#pragma mark - MPPrintDelegate

- (void)didFinishPrintFlow:(UIViewController *)printViewController
{
    NSString *offramp = [self.printItem.extra objectForKey:kMetricsOfframpKey];
    if (offramp) {
        [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:offramp printItem:self.printItem exendedInfo:[self extendedMetrics]];
    } else {
        PGLogError(@"Print from client UI missing offramp key in print item");
    }
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController
{
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MPPrintDataSource

- (void)imageForPaper:(MPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    UIImage *image = [self.imageContainer screenshotImage];
    if (completion) {
        completion(image);
    }
}

- (void)printingItemForPaper:(MPPaper *)paper withCompletion:(void (^)(MPPrintItem *))completion
{
    [self imageForPaper:paper withCompletion:^(UIImage *image) {
        self.printItem = [MPPrintItemFactory printItemWithAsset:image];
        self.printItem.layout = [self layout];
        if (completion) {
            completion(self.printItem);
        }
    }];
}

- (void)previewImageForPaper:(MPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    [self imageForPaper:paper withCompletion:completion];
}

#pragma mark - UIPopoverPresentationControllerDelegate

// NOTE: The implementation of this delegate with the default value is a workaround to compensate an error in the new popover presentation controller of the SDK 8. This fix corrects the case where if the user keep tapping repeatedly the share button in an iPad iOS 8, the app goes back to the first screen.
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}

@end
