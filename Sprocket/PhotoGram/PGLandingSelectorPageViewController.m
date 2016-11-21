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

#import <HPPRFlickrPhotoProvider.h>
#import <HPPRFacebookPhotoProvider.h>
#import <HPPRInstagramPhotoProvider.h>
#import <HPPRCameraRollPhotoProvider.h>
#import <HPPRSelectPhotoCollectionViewController.h>
#import <HPPRSelectAlbumTableViewController.h>
#import <HPPR.h>

#import "PGLandingSelectorPageViewController.h"
#import "PGInstagramLandingPageViewController.h"
#import "PGFacebookLandingPageViewController.h"
#import "PGFlickrLandingPageViewController.h"
#import "PGQzoneLandingPageViewController.h"
#import "PGCameraRollLandingPageViewController.h"
#import "PGPituLandingPageViewController.h"
#import "SWRevealViewController.h"
#import "PGSwipeCoachMarksView.h"
#import "PGMediaNavigation.h"
#import "PGCameraManager.h"
#import "MP.h"
#import "PGPreviewViewController.h"

#define NUMBER_OF_LANDING_PAGE_VIEW_CONTROLLERS 5
#define INITIAL_LANDING_PAGE_SELECTED_INDEX 0

#define PAGE_CONTROL_HEIGHT 20

NSString * const kSettingShowSwipeCoachMarks = @"SettingShowSwipeCoachMarks";

@interface PGLandingSelectorPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, PGMediaNavigationDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSArray<PGSocialSource *> *socialSources;
@property (nonatomic, strong) NSArray<UINavigationController *> *socialViewControllers;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) PGMediaNavigation *navigationView;
@property (nonatomic, strong) PGSwipeCoachMarksView *swipeCoachMarksView;
@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation PGLandingSelectorPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSocialNetworkNotification:) name:SHOW_SOCIAL_NETWORK_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enablePageControllerFunctionalityNotification:) name:ENABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disablePageControllerFunctionalityNotification:) name:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSwipeCoachMarks:) name:SHOW_SWIPE_COACH_MARKS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSwipeCoachMarks:) name:HIDE_SWIPE_COACH_MARKS_NOTIFICATION object:nil];

    self.dataSource = self;
    self.delegate = self;
    
    self.view.accessibilityIdentifier = @"Landing Page View Controller";

    [self setupSocialSources];

    UINavigationController *navController = [self viewControllerForSocialSourceType:self.socialSourceType];
    
    if (nil == navController) {
        [self setViewControllers:@[[self.socialViewControllers firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    } else {
        [self setViewControllers:@[navController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        if (self.includeLogin) {
            PGLandingPageViewController *landingPageViewController = (PGLandingPageViewController *) navController.topViewController;
            [landingPageViewController performSelector:@selector(showLogin) withObject:nil afterDelay:1.0];
        }

    }

    [self showNavigationView];
    [self initPageControl];
    
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            self.scrollView = (UIScrollView *)v;
            self.scrollView.delegate = self;
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Social Sources

- (void)setupSocialSources
{
    self.socialSources = [[PGSocialSourcesManager sharedInstance] enabledSocialSources];

    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:self.socialSources.count];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    for (PGSocialSource *socialSource in self.socialSources) {
        switch (socialSource.type) {
            case PGSocialSourceTypeLocalPhotos: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGCameraRollLandingPageViewNavigationController"];
                viewController.delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypeInstagram: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGInstagramLandingPageViewNavigationController"];
                viewController.delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypeFacebook: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGFacebookLandingPageViewNavigationController"];
                viewController.delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypeFlickr: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGFlickrLandingPageViewNavigationController"];
                viewController.delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypeWeiBo: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGFacebookLandingPageViewNavigationController"];
                viewController.delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypeQzone: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGQzoneLandingPageViewNavigationController"];
                viewController.delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypePitu: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPituLandingPageViewNavigationController"];
                viewController.delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
        }
    }

    self.socialViewControllers = [viewControllers copy];
}


#pragma mark - Notifications

- (void)handleMenuOpenedNotification:(NSNotification *)notification
{
    [self disableSwipe];
}

- (void)handleMenuClosedNotification:(NSNotification *)notification
{
    [self enableSwipe];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (UINavigationController *)viewControllerForSocialSourceType:(PGSocialSourceType)socialSourceType
{
    for (int i = 0; i < self.socialSources.count; i++) {
        PGSocialSource *socialSource = self.socialSources[i];

        if (socialSourceType == socialSource.type) {
            return self.socialViewControllers[i];
        }
    }

    return nil;
}

- (void)showSocialNetworkNotification:(NSNotification *)notification
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    PGSocialSourceType socialSourceType = [[notification.userInfo objectForKey:kSocialNetworkKey] unsignedIntegerValue];
    BOOL includeLogin = [[notification.userInfo objectForKey:kIncludeLoginKey] boolValue];
    
    UINavigationController *viewController = [self viewControllerForSocialSourceType:socialSourceType];
    
    [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    self.pageControl.currentPage = [self pageForSocialNetwork:socialSourceType];
    self.pageControl.accessibilityValue = [NSString stringWithFormat:@"%ld", (long)self.pageControl.currentPage];

    if (includeLogin) {
        if ([viewController.topViewController isKindOfClass:[PGLandingPageViewController class]]) {
            PGLandingPageViewController *landingPageViewController = (PGLandingPageViewController *) viewController.topViewController;
            [landingPageViewController performSelector:@selector(showLogin) withObject:nil afterDelay:1.0];
        }
    }
}

- (void)enablePageControllerFunctionalityNotification:(NSNotification *)notification
{
    [self enableSwipe];
    
    //Not pulling the page control out just yet
    //self.pageControl.hidden = NO;
}

- (void)disablePageControllerFunctionalityNotification:(NSNotification *)notification
{
    [self disableSwipe];
    
    self.pageControl.hidden = YES;
}

#pragma mark - Utils


- (void)enableSwipe
{
    for (UIScrollView *scrollView in self.view.subviews) {
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            scrollView.scrollEnabled = YES;
        }
    }
}

- (void)disableSwipe
{
    for (UIScrollView *scrollView in self.view.subviews) {
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            scrollView.scrollEnabled = NO;
        }
    }
}

-(BOOL)coachMarksHaveBeenShown
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil == [defaults objectForKey:kSettingShowSwipeCoachMarks]) {
        [defaults setBool:YES forKey:kSettingShowSwipeCoachMarks];
        [defaults synchronize];
    }
    return ![defaults boolForKey:kSettingShowSwipeCoachMarks];
}

- (void)showSwipeCoachMarks:(NSNotification *)notification
{
    if( ![self coachMarksHaveBeenShown] ) {
        if (self.swipeCoachMarksView == nil) {
            self.swipeCoachMarksView = [[PGSwipeCoachMarksView alloc] initWithFrame:self.view.frame];
            self.swipeCoachMarksView.alpha = 0.0f;
            
            [self.view addSubview:self.swipeCoachMarksView];
            [self.view bringSubviewToFront:self.swipeCoachMarksView];
            
            [UIView animateWithDuration:COACH_MARK_ANIMATION_DURATION animations:^{
                self.swipeCoachMarksView.alpha = 1.0f;
            } completion:nil];
        }
    }
}

- (void)showNavigationView
{
    if (self.navigationView == nil) {
        self.navigationView = [[PGMediaNavigation alloc] initWithFrame:self.view.frame];
        self.navigationView.delegate = self;
        self.navigationView.alpha = 1.0f;
        
        [self.view addSubview:self.navigationView];
        [self.view bringSubviewToFront:self.navigationView];
    }
}

- (void)hideSwipeCoachMarks:(NSNotification *)notification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:kSettingShowSwipeCoachMarks];
    [defaults synchronize];

    [UIView animateWithDuration:COACH_MARK_ANIMATION_DURATION animations:^{
        self.swipeCoachMarksView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.swipeCoachMarksView removeFromSuperview];
    }];
}

- (void)initPageControl
{
    // Note: The default page control of the UIPageViewController doesn't allow to overlay the view controllers behind it, so for putting the page control with a transparent background on top of them it is necessary to implement our own page control and not use the default one provided by UIPageViewController. The proper way to add subviews is using autolayout constraints but in iOS 7 is not possible to add subviews with autolayout constraints to the UIPageViewController, it throws an exception: "Auto Layout still required after executing -layoutSubviews", so in this case it is implemented using frames.
    self.pageControl = [[UIPageControl alloc] init];
    
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.pageControl];
    [self.view bringSubviewToFront:self.pageControl];
    
    NSDictionary *viewsDictionary = @{@"pageControl":self.pageControl};
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[pageControl(20)]|"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[pageControl]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    self.pageControl.numberOfPages = NUMBER_OF_LANDING_PAGE_VIEW_CONTROLLERS;
    self.pageControl.currentPage = [self pageForSocialNetwork:self.socialSourceType];

    self.pageControl.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];

    self.pageControl.pageIndicatorTintColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRButtonTitleColorNormal];
    self.pageControl.currentPageIndicatorTintColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRButtonTitleColorSelected];
    
    self.pageControl.accessibilityIdentifier = @"Dot View For Page Navigation";
    self.pageControl.accessibilityValue = @"0";

    //Not pulling the page control out just yet
    self.pageControl.hidden = YES;
}

- (void)setSocialSourceType:(PGSocialSourceType)socialSourceType
{
    _socialSourceType = socialSourceType;
}

- (UINavigationController *)currentNavigationController
{
    return [self viewControllerForSocialSourceType:self.socialSourceType];
}

- (NSInteger)pageForSocialNetwork:(PGSocialSourceType)socialSourceType
{
    NSInteger page = 0;

    for (int i = 0; i < self.socialSources.count; i++) {
        PGSocialSource *socialSource = self.socialSources[i];

        if (socialSourceType == socialSource.type) {
            page = i;
        }
    }

    return page;
}


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    NSUInteger index = [self.socialViewControllers indexOfObject:navigationController];

    if (index != NSNotFound) {
        PGSocialSource *socialSource = self.socialSources[index];

        BOOL isShowingPhotoGallery = [viewController isKindOfClass:[HPPRSelectPhotoCollectionViewController class]];

        if (isShowingPhotoGallery && socialSource.hasFolders) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_ALBUMS_FOLDER_ICON object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_ALBUMS_FOLDER_ICON object:nil];
        }

        [self.navigationView selectButton:socialSource.title animated:YES];
    }
}

#pragma mark - PGMediaNavigationDelegate

- (void)mediaNavigationDidPressMenuButton:(PGMediaNavigation *)mediaNav
{
    PGLandingPageViewController *vc = (PGLandingPageViewController *)([self currentNavigationController].viewControllers[0]);
    [vc.revealViewController revealToggle:self];
}

- (void)mediaNavigationDidPressFolderButton:(PGMediaNavigation *)mediaNav
{
    UINavigationController *navController = [self currentNavigationController];

    BOOL popped = NO;

    for (UIViewController *vc in navController.viewControllers) {
        if ([vc isKindOfClass:[HPPRSelectAlbumTableViewController class]]) {
            [navController popToViewController:vc animated:YES];
            popped = YES;
            break;
        }
    }
    
    if (!popped) {
        PGLandingPageViewController *landingPage = (PGLandingPageViewController *)navController.viewControllers[0];
        [landingPage showAlbums];
    }
}

- (void)mediaNavigationDidPressCameraButton:(PGMediaNavigation *)mediaNav
{
    __weak PGLandingSelectorPageViewController *weakSelf = self;
    [[PGCameraManager sharedInstance] checkCameraPermission:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
        previewViewController.source = [PGPreviewViewController cameraSource];
        previewViewController.transitionEffectView.alpha = 1;
        
        [weakSelf presentViewController:previewViewController animated:YES completion:nil];
    } andFailure:^{
        [[PGCameraManager sharedInstance] showCameraPermissionFailedAlert];
    }];
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed) {
        return;
    }
    
    UINavigationController *viewController = [pageViewController.viewControllers lastObject];

    NSUInteger index = [self.socialViewControllers indexOfObject:viewController];

    if (index != NSNotFound) {
        PGSocialSource *socialSource = self.socialSources[index];

        self.pageControl.currentPage = [self pageForSocialNetwork:socialSource.type];
        [self.navigationView selectButton:socialSource.title animated:YES];
        self.socialSourceType = socialSource.type;
    }

    self.pageControl.accessibilityValue = [NSString stringWithFormat:@"%ld", (long)self.pageControl.currentPage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // The scroll view appears to store only 3 screens at a time...
    //  the current screen, one to the left, and one to the right.
    //  Thus 33% is always the origin of the current screen
    CGFloat progress = scrollView.contentOffset.x / scrollView.contentSize.width;    
    progress -= .33F;
    
    [self.navigationView setScrollProgress:scrollView progress:progress forPage:self.pageControl.currentPage];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self.socialViewControllers indexOfObject:(UINavigationController *) viewController];

    if (index != NSNotFound) {
        index = (index + 1) % self.socialSources.count;

        return self.socialViewControllers[index];
    }

    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self.socialViewControllers indexOfObject:(UINavigationController *) viewController];

    if (index != NSNotFound) {
        // the modulus operator fails basic arithmetic...
        if (0 == index) {
            index = self.socialSources.count-1;
        } else {
            index = ((index - 1) % self.socialSources.count);
        }

        return self.socialViewControllers[index];
    }

    return nil;
}

@end
