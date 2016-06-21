//
//  PGPreviewViewController.m
//  Sprocket
//
//  Created by Susy Snowflake on 6/20/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "PGPreviewViewController.h"
#import "PGSaveToCameraRollActivity.h"
#import "PGAnalyticsManager.h"
#import "UINavigationBar+FixedHeightWhenStatusBarHidden.h"

#import <MP.h>
#import <MPPrintItemFactory.h>
#import <MPLayoutFactory.h>
#import <MPPrintActivity.h>
#import <MPPrintLaterActivity.h>

#define kPreviewScreenshotErrorTitle NSLocalizedString(@"Oops!", nil)
#define kPreviewScreenshotErrorMessage NSLocalizedString(@"An error occurred when sharing the item.", nil)
#define kPreviewRetryButtonTitle NSLocalizedString(@"Retry", nil)
static NSInteger const screenshotErrorAlertViewTag = 100;
static NSString * const kSettingShowPrintQCoachMarks = @"SettingShowPrintQCoachMarks";

@interface PGPreviewViewController() <MPPrintDataSource, UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) MPPrintItem *printItem;
@property (strong, nonatomic) MPPrintLaterJob *printLaterJob;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) UIPopoverController *popover;

@end

@implementation PGPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.selectedPhoto) {
        self.printItem = [MPPrintItemFactory printItemWithAsset:self.selectedPhoto];
        self.printItem.layout = [self prepareLayout];
        
        self.imageView.image = [self.printItem previewImageForPaper:[MP sharedInstance].defaultPaper];
    }
    
    CGRect frame = self.imageView.frame;
    frame.size.height = 1.5 * self.imageView.frame.size.width;
    self.imageView.frame = frame;

    self.navigationController.navigationBar.fixedHeightWhenStatusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)setSelectedPhoto:(UIImage *)selectedPhoto
{
    UIImage *finalImage = selectedPhoto;
    
    if (selectedPhoto.size.width > selectedPhoto.size.height) {
        finalImage = [[UIImage alloc] initWithCGImage: selectedPhoto.CGImage
                                                scale: 1.0
                                          orientation: UIImageOrientationRight];
    }
    _selectedPhoto = finalImage;
}
- (IBAction)didPressCameraButton:(id)sender {
}

- (IBAction)didPressCloseButton:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressEditButton:(id)sender {
}

- (IBAction)didPressPrinterButton:(id)sender {
}

- (IBAction)didPressShareButton:(id)sender {
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

#pragma mark - Print preparation

- (MPLayout *)prepareLayout
{
    return [MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]];
}

- (NSDictionary *)extendedMetrics
{
    return @{
             //             kMetricsTypeLocationKey:[self locationMetrics],
             kMetricsTypePhotoSourceKey:[[PGAnalyticsManager sharedManager] photoSourceMetrics],
             //             kMetricsTypePhotoPositionKey:[[PGAnalyticsManager sharedManager] photoPositionMetricsWithOffset:self.svgLoader.offset zoom:self.svgLoader.zoom angle:self.svgLoader.angle]
             };
}

- (void)printLaterItemsWithCompletion:(void (^)(NSDictionary *result))completion
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:1];
    
    MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:self.imageView.image];
    printItem.layout = [self prepareLayout];
    
    [result setValue:printItem forKey:[MP sharedInstance].defaultPaper.sizeTitle];
    
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
                    // The user is using the print queue... suppress intro-to-print-queue coach marks
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:NO forKey:kSettingShowPrintQCoachMarks];
                    [defaults synchronize];
                }
            } else {
                if (activityType) {
                    [[PGAnalyticsManager sharedManager] trackShareActivity:offramp withResult:kEventResultCancel];
                }
            }
            
            // if the user has seen the PrintLater offering, don't give them a coach mark for it in the future
            if (printLaterActivity) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:NO forKey:kSettingShowPrintQCoachMarks];
                [defaults synchronize];
            }
        };
        
        activityViewController.popoverPresentationController.sourceRect = self.shareButton.bounds;
        activityViewController.popoverPresentationController.sourceView = self.shareButton;
        activityViewController.popoverPresentationController.delegate = self;
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

#pragma mark - MPPrintDataSource

- (void)imageForPaper:(MPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    UIImage *image = self.imageView.image;
    if (completion) {
        completion(image);
    }
}

- (void)printingItemForPaper:(MPPaper *)paper withCompletion:(void (^)(MPPrintItem *))completion
{
    [self imageForPaper:paper withCompletion:^(UIImage *image) {
        self.printItem = [MPPrintItemFactory printItemWithAsset:image];
        self.printItem.layout = [self prepareLayout];
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
