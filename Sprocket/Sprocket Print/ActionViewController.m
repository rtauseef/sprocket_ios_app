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

#import "ActionViewController.h"
#import "PGBaseAnalyticsManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MP.h>
#import <MPPrintItemFactory.h>
#import <MPLayoutFactory.h>
#import <MPPrintManager.h>
#import "PGGesturesView.h"
#import "UIView+Background.h"
#import "PGBatteryImageView.h"

static NSUInteger const kActionViewControllerPrinterConnectivityCheckInterval = 1;
static NSInteger  const connectionDefaultValue = -1;

@interface ActionViewController () <MPSprocketDelegate>

@property (weak, nonatomic) IBOutlet PGGesturesView *gesturesView;
@property (weak, nonatomic) IBOutlet UIButton *printButton;

@property (strong, nonatomic) CAGradientLayer *gradient;
@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;
@property (weak, nonatomic) IBOutlet PGBatteryImageView *batteryIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *printerDot;

@property (strong, nonatomic) NSTimer *sprocketConnectivityTimer;
@property (assign, nonatomic) NSInteger lastConnectedValue;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MP sharedInstance].extensionController = self;
    [MP sharedInstance].handlePrintMetricsAutomatically = NO;
    [MP sharedInstance].uniqueDeviceIdPerApp = NO;
    
    self.printButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.printButton.layer.borderWidth = 1.0f;
    self.printButton.layer.cornerRadius = 3.5f;
    
    self.printButton.titleLabel.minimumScaleFactor = 0.5f;
    self.printButton.titleLabel.numberOfLines = 1;
    self.printButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.printButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    [self addGradientBackgroundToView:self.view];
    
    BOOL imageFound = NO;
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                __weak ActionViewController *weakSelf = self;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if (image) {
                        UIImage *finalImage = image;
                        
                        if (image.size.width > image.size.height) {
                            finalImage = [[UIImage alloc] initWithCGImage: image.CGImage
                                                                    scale: 1.0
                                                              orientation: UIImageOrientationRight];
                        }

                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [weakSelf renderPhoto:finalImage];
                        }];
                    }
                }];
                
                imageFound = YES;
                break;
            }
        }
        
        if (imageFound) {
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkSprocketPrinterConnectivity:nil];
    
    self.sprocketConnectivityTimer = [NSTimer scheduledTimerWithTimeInterval:kActionViewControllerPrinterConnectivityCheckInterval target:self selector:@selector(checkSprocketPrinterConnectivity:) userInfo:nil repeats:YES];
    
    self.lastConnectedValue = connectionDefaultValue;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintJobCompletedNotification:) name:kMPBTPrintJobCompletedNotification object:nil];

    [[MP sharedInstance] checkSprocketForUpdates:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.sprocketConnectivityTimer invalidate];
    self.sprocketConnectivityTimer = nil;
    self.lastConnectedValue = connectionDefaultValue;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)checkSprocketPrinterConnectivity:(NSTimer *)timer
{
    NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
    BOOL currentlyConnected = (numberOfPairedSprockets > 0);

    if (currentlyConnected) {
        [self.printerDot setImage:[UIImage imageNamed:@"ptsActive"]];
        self.connectedLabel.hidden = NO;
        self.batteryIndicator.hidden = (1 != numberOfPairedSprockets);
    } else {
        self.connectedLabel.hidden = YES;
        self.batteryIndicator.hidden = YES;
        [self.printerDot setImage:[UIImage imageNamed:@"ptsInactive"]];
    }

    if (connectionDefaultValue != self.lastConnectedValue  &&
        self.lastConnectedValue != currentlyConnected) {
        [[PGBaseAnalyticsManager sharedManager] trackPrinterConnected:(BOOL)currentlyConnected screenName:@"Share Extension"];
    }
    
    self.lastConnectedValue = currentlyConnected;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.gradient.frame = self.view.bounds;
        
        [self.view layoutIfNeeded];
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)addGradientBackgroundToView:(UIView *)view {
    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = view.frame;
    self.gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0x1f/255.0F green:0x1f/255.0F blue:0x1f/255.0F alpha:1] CGColor], (id)[[UIColor colorWithRed:0x38/255.0F green:0x38/255.0F blue:0x38/255.0F alpha:1] CGColor], nil];
    self.gradient.startPoint = CGPointMake(0, 1);
    self.gradient.endPoint = CGPointMake(1, 0);
    [view.layer insertSublayer:self.gradient atIndex:0];
}

- (void)renderPhoto:(UIImage *)photo {
    [self.gesturesView setImage:photo];
    self.gesturesView.doubleTapBehavior = PGGesturesDoubleTapReset;
    
    [self.gesturesView layoutIfNeeded];
    [self.gesturesView setNeedsDisplay];
}

- (IBAction)printTapped:(id)sender {
    UIImage *image = [self.gesturesView screenshotImage];
    [[MP sharedInstance] headlessBluetoothPrintFromController:self image:image animated:YES printCompletion:nil];
}

- (IBAction)done {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

#pragma mark - MPSprocketDelegate

- (void)didReceiveSprocketBatteryLevel:(NSUInteger)batteryLevel
{
    self.batteryIndicator.level = batteryLevel;
}

#pragma mark - Print Notification Handler

- (void)handlePrintJobCompletedNotification:(NSNotification *)notification
{
    NSString *error = [notification.userInfo objectForKey:kMPBTPrintJobErrorKey];
    
    if (nil == error) {
        MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:[self.gesturesView screenshotImage]];
        printItem.layout = [MPLayoutFactory layoutWithType:[MPLayoutFill layoutType]];
        
        [[PGBaseAnalyticsManager sharedManager] postMetricsWithOfframp:[MPPrintManager printFromActionExtension] printItem:printItem extendedInfo:nil];

    }
}

@end
