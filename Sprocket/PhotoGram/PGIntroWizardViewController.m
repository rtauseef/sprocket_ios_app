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

#import "UIColor+HexString.h"
#import "PGIntroWizardViewController.h"
#import "PGAnalyticsManager.h"
#import "PGAttributedLabel.h"
#import "MP.h"


@interface PGIntroWizardViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) NSArray<UIViewController *> *pages;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSTimer *printerConnectedCheckTimer;

@end

@implementation PGIntroWizardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pageViewController = [self.childViewControllers firstObject];

    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UIViewController *page1 = [sb instantiateViewControllerWithIdentifier:@"IntroWizardPage1"];
    UIViewController *page2 = [sb instantiateViewControllerWithIdentifier:@"IntroWizardPage2"];
    UIViewController *page3 = [sb instantiateViewControllerWithIdentifier:@"IntroWizardPage3"];
    


    self.pages = @[page1, page2, page3];
    
    [self setupStepLabels];

    [self.pageViewController setViewControllers:@[page1]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    [self trackPageView:[self.pages firstObject]];

    self.printerConnectedCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                       target:self
                                                                     selector:@selector(skipWizardIfConnected)
                                                                     userInfo:nil
                                                                      repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.printerConnectedCheckTimer invalidate];
    self.printerConnectedCheckTimer = nil;
}

- (void)skipWizardIfConnected
{
    if ([[MP sharedInstance] numberOfPairedSprockets] > 0) {
        [self performSegueWithIdentifier:@"SkipWizardSegue" sender:self];
    }
}

- (void)trackPageView:(UIViewController *)viewController
{
    NSUInteger index = [self.pages indexOfObject:viewController];

    if (index != NSNotFound) {
        NSString *screenName = [NSString stringWithFormat:@"StartWizard - Screen%lu", (index + 1)];

        [[PGAnalyticsManager sharedManager] trackScreenViewEvent:screenName];
    }
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    [self trackPageView:[pendingViewControllers firstObject]];
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pages indexOfObject:viewController];

    if (index == 0) {
        return nil;
    }

    index--;
    return [self.pages objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pages indexOfObject:viewController];
    index++;

    if (index >= self.pages.count) {
        return nil;
    }

    return [self.pages objectAtIndex:index];
}

#pragma mark - Load UI Methods
- (void)setupStepLabels
{
    if ([self.pages count] <3)
        return;
    
    NSString *stepOne = NSLocalizedString(@"Step 1", @"Setup step 1 title");
    NSString *stepTwo = NSLocalizedString(@"Step 2", @"Setup step 2 title");
    NSString *stepThree = NSLocalizedString(@"Step 3", @"Setup step 3 title");

    NSString *stepOneDesc = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Load Paper", @"Setup step 1 desc")];
    NSString *stepTwoDesc = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Power Up", @"Setup step 2 desc")];
    NSString *stepThreeDesc = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Connect", @"Setup step 3 desc")];
    
    NSInteger wizardTab1Tag = 101;
    NSInteger wizardTab2Tag = 102;
    NSInteger wizardTab3Tag = 103;
    
    PGAttributedLabel *wizardTab1 =  [self.pages[0].view viewWithTag:wizardTab1Tag];
    PGAttributedLabel *wizardTab2 =  [self.pages[1].view viewWithTag:wizardTab2Tag];
    PGAttributedLabel *wizardTab3 =  [self.pages[2].view viewWithTag:wizardTab3Tag];

    [self setupStepLabel:wizardTab1 step:stepOne desc:stepOneDesc];
    [self setupStepLabel:wizardTab2 step:stepTwo desc:stepTwoDesc];
    [self setupStepLabel:wizardTab3 step:stepThree desc:stepThreeDesc];
}


- (void)setupStepLabel:(PGAttributedLabel *)label step:(NSString *)step desc:(NSString *)desc
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:step attributes:nil];
    
    [attributedText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:desc]];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0096D6"] range:NSMakeRange(step.length, desc.length)];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:label.fontFamily size:label.fontSize] range:NSMakeRange(0, attributedText.length)];
    label.attributedText = attributedText;
}

@end
