//
//  PGPreviewViewController.m
//  Sprocket
//
//  Created by Susy Snowflake on 6/20/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "PGPreviewViewController.h"
#import "PGSaveToCameraRollActivity.h"
#import <MP.h>
#import <MPPrintActivity.h>
#import <MPPrintLaterActivity.h>

@interface PGPreviewViewController() <MPPrintDataSource>

@property (strong, nonatomic) MPPrintLaterJob *printLaterJob;

@end

@implementation PGPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
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

- (void)printLaterItemsWithCompletion:(void (^)(NSDictionary *result))completion
{
    NSArray *paperSizes = [MP sharedInstance].supportedPapers;
    
    NSMutableDictionary *partialResult = [NSMutableDictionary dictionaryWithCapacity:paperSizes.count];
    
    [self printLaterItemForIndex:0 partialResult:partialResult withCompletion:^(NSDictionary *result) {
        if (completion) {
            completion(result);
        }
    }];
}

- (void)preparePrintJobWithCompletion:(void(^)(void))completion
{
    NSString *printLaterJobNextAvailableId = [[MP sharedInstance] nextPrintJobId];
    self.printLaterJob = [[MPPrintLaterJob alloc] init];
    self.printLaterJob.id = printLaterJobNextAvailableId;
self.printLaterJob.name = @"name";
    self.printLaterJob.date = [NSDate date];
//    self.printLaterJob.extra = [self extendedMetrics];
    [self printLaterItemsWithCompletion:^(NSDictionary *result) {
        self.printLaterJob.printItems = result;
        if (completion) {
            completion();
        }
    }];
}

- (void)presentActivityViewControllerWithActivities:(NSArray *)applicationActivities
{
    [self preparePrintItem];
    
    if (nil == self.printItem) {
        // NOTE. We couldn't recreate this situation, but there is a crash reported in crashlytics indicating that this has happened: Crash 1.3(995) #81
        if (NSClassFromString(@"UIAlertController") != nil) {
            UIAlertController *errorScreenshotController = [UIAlertController alertControllerWithTitle:kScreenshotErrorTitle message:kScreenshotErrorMessage preferredStyle:UIAlertControllerStyleAlert];
            [errorScreenshotController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
            [errorScreenshotController addAction:[UIAlertAction actionWithTitle:kRetryButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self shareItem];
            }]];
            
            [self presentViewController:errorScreenshotController animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kScreenshotErrorTitle message:kScreenshotErrorMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:kRetryButtonTitle, nil];
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
            
            [self removeFalseFront];
            
            self.returningFromShareActivity = FALSE;
        };
        
        self.returningFromShareActivity = TRUE;
        if (IS_IPAD && !IS_OS_8_OR_LATER) {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            [self.popover presentPopoverFromBarButtonItem:self.shareButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            if (IS_OS_8_OR_LATER) {
                activityViewController.popoverPresentationController.barButtonItem = self.shareButtonItem;
                activityViewController.popoverPresentationController.delegate = self;
            }
            
            [self presentViewController:activityViewController animated:YES completion:nil];
        }
    }
}

@end
