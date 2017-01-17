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
#import "PGSetupSprocketViewController.h"

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
    [self setupStepContent];

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

    NSInteger wizardTab1Tag = 101;
    NSInteger wizardTab2Tag = 102;
    NSInteger wizardTab3Tag = 103;
    
    PGAttributedLabel *wizardTab1 =  [self.pages[0].view viewWithTag:wizardTab1Tag];
    PGAttributedLabel *wizardTab2 =  [self.pages[1].view viewWithTag:wizardTab2Tag];
    PGAttributedLabel *wizardTab3 =  [self.pages[2].view viewWithTag:wizardTab3Tag];

    [PGSetupSprocketViewController setStepOneLabelText:wizardTab1];
    [PGSetupSprocketViewController setStepTwoLabelText:wizardTab2];
    [PGSetupSprocketViewController setStepThreeLabelText:wizardTab3];
}

- (void)setupStepContent
{
    if ([self.pages count] <3)
        return;
    
    NSInteger tab1ContentTag = 201;
    NSInteger tab2ContentTag = 202;
    NSInteger tab3ContentTag = 203;
    
    UILabel *tab1ContentLabel =  [self.pages[0].view viewWithTag:tab1ContentTag];
    UILabel *tab2ContentLabel =  [self.pages[1].view viewWithTag:tab2ContentTag];
    UILabel *tab3ContentLabel =  [self.pages[2].view viewWithTag:tab3ContentTag];
    
    tab1ContentLabel.text = [PGSetupSprocketViewController stepOneContentText];
    
    tab2ContentLabel.text = [PGSetupSprocketViewController stepTwoContentText];

    tab3ContentLabel.text = [PGSetupSprocketViewController stepThreeContentText];
}

@end
