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

@interface ActionViewController () <MPSprocketDelegate>

@property (strong, nonatomic) PGGesturesView *imageView;
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (weak, nonatomic) IBOutlet UIButton *printButton;

@property (strong, nonatomic) CAGradientLayer *gradient;
@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;
@property (weak, nonatomic) IBOutlet PGBatteryImageView *batteryIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *printerDot;

@property (strong, nonatomic) NSTimer *sprocketConnectivityTimer;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MP sharedInstance].extensionController = self;
    [MP sharedInstance].handlePrintMetricsAutomatically = NO;
    
    self.printButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.printButton.layer.borderWidth = 1.0f;
    self.printButton.layer.cornerRadius = 3.5f;
    
    [self addGradientBackgroundToView:self.view];
    
    BOOL imageFound = NO;
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                __weak ActionViewController *weakSelf = self;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if (image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [weakSelf renderPhoto:image];
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
    
    [[MP sharedInstance] checkSprocketForUpdates:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.sprocketConnectivityTimer invalidate];
    self.sprocketConnectivityTimer = nil;
}

- (void)checkSprocketPrinterConnectivity:(NSTimer *)timer
{
    NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
    
    if (numberOfPairedSprockets > 0) {
        [self.printerDot setImage:[UIImage imageNamed:@"ptsActive"]];
        self.connectedLabel.hidden = NO;
        self.batteryIndicator.hidden = NO;
    } else {
        self.connectedLabel.hidden = YES;
        self.batteryIndicator.hidden = YES;
        [self.printerDot setImage:[UIImage imageNamed:@"ptsInactive"]];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.imageView.frame = self.imageContainer.bounds;
        self.imageView.scrollView.frame = self.imageContainer.bounds;
        [self.imageView adjustScrollAndImageView];
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
    self.imageView = [[PGGesturesView alloc] initWithFrame:self.imageContainer.bounds];
    self.imageView.image = photo;
    self.imageView.doubleTapBehavior = PGGesturesDoubleTapReset;
    
    [self.imageContainer addSubview:self.imageView];
}

- (IBAction)printTapped:(id)sender {
    UIImage *image = [self.imageContainer screenshotImage];
    [[MP sharedInstance] headlessBluetoothPrintFromController:self image:image animated:YES printCompletion:^(){
        MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:image];
        printItem.layout = [MPLayoutFactory layoutWithType:[MPLayoutFill layoutType]];

        [[PGBaseAnalyticsManager sharedManager] postMetricsWithOfframp:[MPPrintManager printFromActionExtension] printItem:printItem exendedInfo:nil];
    }];
}

- (IBAction)done {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

#pragma mark - MPSprocketDelegate

- (void)didReceiveSprocketBatteryLevel:(NSUInteger)batteryLevel
{
    self.batteryIndicator.level = batteryLevel;
}


@end
