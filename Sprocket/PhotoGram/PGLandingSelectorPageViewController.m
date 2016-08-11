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
#import "PGCameraRollLandingPageViewController.h"
#import "SWRevealViewController.h"
#import "PGSideBarMenuTableViewController.h"
#import "PGSwipeCoachMarksView.h"
#import "PGMediaNavigation.h"
#import "PGCameraManager.h"
#import "MP.h"
#import "PGPreviewViewController.h"

#define NUMBER_OF_LANDING_PAGE_VIEW_CONTROLLERS 4
#define INITIAL_LANDING_PAGE_SELECTED_INDEX 0

#define PAGE_CONTROL_HEIGHT 20

NSString * const kSettingShowSwipeCoachMarks = @"SettingShowSwipeCoachMarks";

typedef enum {
    PGLandingPageViewControlIndexInstagram = 0,
    PGLandingPageViewControlIndexFacebook = 1,
    PGLandingPageViewControlIndexFlickr = 2,
    PGLandingPageViewControlIndexCameraRoll = 3
} PGLandingPageViewControlIndex;

@interface PGLandingSelectorPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, PGMediaNavigationDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) PGMediaNavigation *navigationView;
@property (nonatomic, strong) PGSwipeCoachMarksView *swipeCoachMarksView;
@property (nonatomic, strong) UINavigationController *instagramLandingPageViewController;
@property (nonatomic, strong) UINavigationController *facebookLandingPageViewController;
@property (nonatomic, strong) UINavigationController *cameraRollLandingPageViewController;
@property (nonatomic, strong) UINavigationController *flickrLandingPageViewController;
@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, assign) NSInteger previousPageControlPosition;

@end

@implementation PGLandingSelectorPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSocialNetworkNotification:) name:SHOW_SOCIAL_NETWORK_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enablePageControllerFunctionalityNotification:) name:ENABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disablePageControllerFunctionalityNotification:) name:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSwipeCoachMarks:) name:SHOW_SWIPE_COACH_MARKS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSwipeCoachMarks:) name:HIDE_SWIPE_COACH_MARKS_NOTIFICATION object:nil];

    self.dataSource = self;
    self.delegate = self;
    self.previousPageControlPosition = 0;
    
    self.view.accessibilityIdentifier = @"Landing Page View Controller";
    
    UINavigationController *navController = [self viewControllerForSocialNetwork:self.socialNetwork];
    
    if( nil == navController ) {
        [self setViewControllers:@[self.instagramLandingPageViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    else {
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

#pragma mark - Notifications

- (void)handleMenuOpenedNotification:(NSNotification *)notification
{
    [self disableSwipe];
}

- (void)handleMenuClosedNotification:(NSNotification *)notification
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self enableSwipe];
}

- (UINavigationController *)viewControllerForSocialNetwork:(NSString *)socialNetwork
{
    UINavigationController *viewController = nil;
    
    if ([socialNetwork isEqualToString:[HPPRInstagramPhotoProvider sharedInstance].name]) {
        viewController = self.instagramLandingPageViewController;
    } else if ([socialNetwork isEqualToString:[HPPRFacebookPhotoProvider sharedInstance].name]) {
        viewController = self.facebookLandingPageViewController;
    } else if ([socialNetwork isEqualToString:[HPPRFlickrPhotoProvider sharedInstance].name]) {
        viewController = self.flickrLandingPageViewController;
    } else if ([socialNetwork isEqualToString:[HPPRCameraRollPhotoProvider sharedInstance].name]) {
        viewController = self.cameraRollLandingPageViewController;
    }

    return viewController;
}

- (void)showSocialNetworkNotification:(NSNotification *)notification
{
    NSString *socialNetwork = [notification.userInfo objectForKey:kSocialNetworkKey];
    NSNumber *includeLogin = [notification.userInfo objectForKey:kIncludeLoginKey];
    
    UINavigationController *viewController = [self viewControllerForSocialNetwork:socialNetwork];
    
    [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    self.pageControl.accessibilityValue = [NSString stringWithFormat:@"%ld", (long)self.pageControl.currentPage];
    
    self.previousPageControlPosition = self.pageControl.currentPage;
    
    if ([includeLogin boolValue]) {
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
    if (IS_OS_8_OR_LATER) {
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
    } else {
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - PAGE_CONTROL_HEIGHT, self.view.frame.size.width, PAGE_CONTROL_HEIGHT)];
        self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [self.view addSubview:self.pageControl];
        [self.view bringSubviewToFront:self.pageControl];
    }
    
    self.pageControl.numberOfPages = NUMBER_OF_LANDING_PAGE_VIEW_CONTROLLERS;
    self.pageControl.currentPage = [self pageForSocialNetwork:self.socialNetwork];

    self.pageControl.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];

    self.pageControl.pageIndicatorTintColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRButtonTitleColorNormal];
    self.pageControl.currentPageIndicatorTintColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRButtonTitleColorSelected];
    
    self.pageControl.accessibilityIdentifier = @"Dot View For Page Navigation";
    self.pageControl.accessibilityValue = @"0";

    [self.pageControl addTarget:self action:@selector(respondToPageControlTouch) forControlEvents:UIControlEventValueChanged];
    
    //Not pulling the page control out just yet
    self.pageControl.hidden = YES;
}

- (void)respondToPageControlTouch
{
    if (self.pageControl.currentPage != self.previousPageControlPosition ) {
        UIViewController *currentViewController = [self.viewControllers objectAtIndex:0];
        
        if (self.pageControl.currentPage > self.previousPageControlPosition) {
            UIViewController *nextViewController = [self pageViewController:self viewControllerAfterViewController:currentViewController];
            [self setViewControllers:@[nextViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        }
        else {
            UIViewController *nextViewController = [self pageViewController:self viewControllerBeforeViewController:currentViewController];
            [self setViewControllers:@[nextViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:NULL];
        }

        self.pageControl.accessibilityValue = [NSString stringWithFormat:@"%ld", (long)self.pageControl.currentPage];

        self.previousPageControlPosition = self.pageControl.currentPage;
    }
}

- (UINavigationController *)currentNavigationController
{
    UINavigationController *navController = nil;
    
    switch (self.pageControl.currentPage) {
        case PGLandingPageViewControlIndexInstagram:
            navController = self.instagramLandingPageViewController;
            break;
            
        case PGLandingPageViewControlIndexFacebook:
            navController = self.facebookLandingPageViewController;
            break;
            
        case PGLandingPageViewControlIndexFlickr:
            navController = self.flickrLandingPageViewController;
            break;
            
        case PGLandingPageViewControlIndexCameraRoll:
            navController = self.cameraRollLandingPageViewController;
            break;
            
        default:
            break;
    }
    
    return navController;
}

- (NSInteger)pageForSocialNetwork:(NSString *)socialNetwork
{
    NSInteger page = PGLandingPageViewControlIndexInstagram;
    
    if ([socialNetwork isEqualToString:[HPPRInstagramPhotoProvider sharedInstance].name]) {
        page = PGLandingPageViewControlIndexInstagram;
    } else if ([socialNetwork isEqualToString:[HPPRFacebookPhotoProvider sharedInstance].name]) {
        page = PGLandingPageViewControlIndexFacebook;
    } else if ([socialNetwork isEqualToString:[HPPRFlickrPhotoProvider sharedInstance].name]) {
        page = PGLandingPageViewControlIndexFlickr;
    } else if ([socialNetwork isEqualToString:[HPPRCameraRollPhotoProvider sharedInstance].name]) {
        page = PGLandingPageViewControlIndexCameraRoll;
    }
    
    return page;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if (navigationController != self.instagramLandingPageViewController  &&
        [viewController isKindOfClass:[HPPRSelectPhotoCollectionViewController class]]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_ALBUMS_FOLDER_ICON object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_ALBUMS_FOLDER_ICON object:nil];
    }
    
    UIViewController *vc = navigationController.viewControllers[0];
    NSString *socialNetwork = nil;
    if ([vc isKindOfClass:[PGInstagramLandingPageViewController class]]) {
        socialNetwork = [HPPRInstagramPhotoProvider sharedInstance].name;
    } else if ([vc isKindOfClass:[PGFacebookLandingPageViewController class]]) {
        socialNetwork = [HPPRFacebookPhotoProvider sharedInstance].name;
    } else if ([vc isKindOfClass:[PGFlickrLandingPageViewController class]]) {
        socialNetwork = [HPPRFlickrPhotoProvider sharedInstance].name;
    } else if ([vc isKindOfClass:[PGCameraRollLandingPageViewController class]]) {
        socialNetwork = [HPPRCameraRollPhotoProvider sharedInstance].name;
    }

    [self.navigationView selectButton:socialNetwork animated:YES];
}

#pragma mark - PGMediaNavigationDelegate

- (void)mediaNavigationDidPressMenuButton:(PGMediaNavigation *)mediaNav
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    PGLandingPageViewController *vc = (PGLandingPageViewController *)([self currentNavigationController].viewControllers[0]);
    [vc.revealViewController revealToggle:self];
}

- (void)mediaNavigationDidPressFolderButton:(PGMediaNavigation *)mediaNav
{
    NSLog(@"LandingSelectorPage: Pressed folder button");
    
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
        previewViewController.source = @"CameraRoll";
        previewViewController.transitionEffectView.alpha = 1;
        
        [weakSelf presentViewController:previewViewController animated:YES completion:nil];
    } andFailure:^{
        [[PGCameraManager sharedInstance] showCameraPermissionFailedAlert];
    }];
}

#pragma mark - Getter methods

- (UINavigationController *)instagramLandingPageViewController
{
    if (!_instagramLandingPageViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        _instagramLandingPageViewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGInstagramLandingPageViewNavigationController"];
        _instagramLandingPageViewController.delegate = self;
    }
    
    return _instagramLandingPageViewController;
}

- (UINavigationController *)facebookLandingPageViewController
{
    if (!_facebookLandingPageViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        _facebookLandingPageViewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGFacebookLandingPageViewNavigationController"];
        _facebookLandingPageViewController.delegate = self;
    }
    
    return _facebookLandingPageViewController;
}

- (UINavigationController *)cameraRollLandingPageViewController
{
    if (!_cameraRollLandingPageViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        _cameraRollLandingPageViewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGCameraRollLandingPageViewNavigationController"];
        _cameraRollLandingPageViewController.delegate = self;
    }
    
    return _cameraRollLandingPageViewController;
}

- (UINavigationController *)flickrLandingPageViewController
{
    if (!_flickrLandingPageViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        _flickrLandingPageViewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGFlickrLandingPageViewNavigationController"];
        _flickrLandingPageViewController.delegate = self;
    }
    
    return _flickrLandingPageViewController;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSLog(@"didFinish: %d, previous: %@, complete: %d", finished, previousViewControllers, completed);
    
    if (!completed) {
        return;
    }
    
    UIViewController *viewController = [pageViewController.viewControllers lastObject];
    
    if (viewController == self.instagramLandingPageViewController) {
        self.pageControl.currentPage = PGLandingPageViewControlIndexInstagram;
        [self.navigationView selectButton:[HPPRInstagramPhotoProvider sharedInstance].name animated:YES];
    } else if (viewController == self.facebookLandingPageViewController) {
        self.pageControl.currentPage = PGLandingPageViewControlIndexFacebook;
        [self.navigationView selectButton:[HPPRFacebookPhotoProvider sharedInstance].name animated:YES];
    } else if (viewController == self.flickrLandingPageViewController) {
        self.pageControl.currentPage = PGLandingPageViewControlIndexFlickr;
        [self.navigationView selectButton:[HPPRFlickrPhotoProvider sharedInstance].name animated:YES];
    } else if (viewController == self.cameraRollLandingPageViewController) {
        self.pageControl.currentPage = PGLandingPageViewControlIndexCameraRoll;
        [self.navigationView selectButton:[HPPRCameraRollPhotoProvider sharedInstance].name animated:YES];
    }
    
    self.pageControl.accessibilityValue = [NSString stringWithFormat:@"%ld", (long)self.pageControl.currentPage];
    
    self.previousPageControlPosition = self.pageControl.currentPage;
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
    UIViewController *nextViewController = nil;
    
    if (viewController == self.instagramLandingPageViewController) {
        nextViewController = self.facebookLandingPageViewController;
    } else if (viewController == self.facebookLandingPageViewController) {
        nextViewController = self.flickrLandingPageViewController;
    } else if (viewController == self.flickrLandingPageViewController) {
        nextViewController = self.cameraRollLandingPageViewController;
    } else if (viewController == self.cameraRollLandingPageViewController) {
        nextViewController = self.instagramLandingPageViewController;
    }
    
    return nextViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    UIViewController *prevViewController = nil;
    
    if (viewController == self.cameraRollLandingPageViewController) {
        prevViewController = self.flickrLandingPageViewController;
    } else if (viewController == self.flickrLandingPageViewController) {
        prevViewController = self.facebookLandingPageViewController;
    } else if (viewController == self.facebookLandingPageViewController) {
        prevViewController = self.instagramLandingPageViewController;
    } else if (viewController == self.instagramLandingPageViewController) {
        prevViewController = self.cameraRollLandingPageViewController;
    }
    
    return prevViewController;
}

@end
