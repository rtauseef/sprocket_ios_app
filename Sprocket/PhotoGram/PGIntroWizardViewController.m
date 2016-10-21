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

#import "PGIntroWizardViewController.h"

@interface PGIntroWizardViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) NSArray<UIViewController *> *pages;
@property (nonatomic, strong) UIPageViewController *pageViewController;

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

    [self.pageViewController setViewControllers:@[page1]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - UIPageViewControllerDelegate



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

@end
