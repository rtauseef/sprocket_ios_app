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

#define INITIAL_LANDING_PAGE_SELECTED_INDEX 0

#define PAGE_CONTROL_HEIGHT 20

NSString * const kSettingShowSwipeCoachMarks = @"SettingShowSwipeCoachMarks";

@interface PGLandingSelectorPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, PGMediaNavigationDelegate, UINavigationControllerDelegate, PGLandingPageViewControllerDelegate>

@property (nonatomic, strong) NSArray<PGSocialSource *> *socialSources;
@property (nonatomic, strong) NSArray<UINavigationController *> *socialViewControllers;
@property (nonatomic, strong) PGMediaNavigation *navigationView;
@property (nonatomic, strong) PGSwipeCoachMarksView *swipeCoachMarksView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isDraggingPage;

@end

@implementation PGLandingSelectorPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showStatusBar];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSocialNetworkNotification:) name:SHOW_SOCIAL_NETWORK_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enablePageControllerFunctionalityNotification:) name:ENABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disablePageControllerFunctionalityNotification:) name:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSwipeCoachMarks:) name:SHOW_SWIPE_COACH_MARKS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSwipeCoachMarks:) name:HIDE_SWIPE_COACH_MARKS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showStatusBar) name:kPGCameraManagerCameraClosed object:nil];

    self.dataSource = self;
    self.delegate = self;
    
    self.view.accessibilityIdentifier = @"Landing Page View Controller";

    [self setupSocialSources];

    UINavigationController *navController = [self viewControllerForSocialSourceType:self.socialSourceType];
    
    if (nil == navController) {
        navController = [self.socialViewControllers firstObject];
        [self setViewControllers:@[navController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    } else {
        [self setViewControllers:@[navController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        if (self.includeLogin) {
            PGLandingPageViewController *landingPageViewController = (PGLandingPageViewController *) navController.topViewController;
            [landingPageViewController performSelector:@selector(showLogin) withObject:nil afterDelay:1.0];
        }

    }

    [self showNavigationView];

    NSUInteger index = [self.socialViewControllers indexOfObject:navController];

    if (index != NSNotFound) {
        UINavigationController *viewController = navController.viewControllers.lastObject;

        PGSocialSource *socialSource = self.socialSources[index];

        [self updateMediaNavigationForViewController:viewController socialSource:socialSource];
    }

    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            self.scrollView = (UIScrollView *)v;
            self.scrollView.delegate = self;
        }
    }
    
    self.isDraggingPage = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)hideStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
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
                ((PGLandingPageViewController *) viewController.viewControllers.firstObject).delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypeInstagram: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGInstagramLandingPageViewNavigationController"];
                viewController.delegate = self;
                ((PGLandingPageViewController *) viewController.viewControllers.firstObject).delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypeFacebook: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGFacebookLandingPageViewNavigationController"];
                viewController.delegate = self;
                ((PGLandingPageViewController *) viewController.viewControllers.firstObject).delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypeFlickr: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGFlickrLandingPageViewNavigationController"];
                viewController.delegate = self;
                ((PGLandingPageViewController *) viewController.viewControllers.firstObject).delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypeWeiBo: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGFacebookLandingPageViewNavigationController"];
                viewController.delegate = self;
                ((PGLandingPageViewController *) viewController.viewControllers.firstObject).delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypeQzone: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGQzoneLandingPageViewNavigationController"];
                viewController.delegate = self;
                ((PGLandingPageViewController *) viewController.viewControllers.firstObject).delegate = self;
                [viewControllers addObject:viewController];
                break;
            }
            case PGSocialSourceTypePitu: {
                UINavigationController *viewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPituLandingPageViewNavigationController"];
                viewController.delegate = self;
                ((PGLandingPageViewController *) viewController.viewControllers.firstObject).delegate = self;
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
    [self showStatusBar];
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
    [self showStatusBar];
    
    PGSocialSourceType socialSourceType = [[notification.userInfo objectForKey:kSocialNetworkKey] unsignedIntegerValue];
    
    if (self.socialSourceType != socialSourceType) {
        BOOL includeLogin = [[notification.userInfo objectForKey:kIncludeLoginKey] boolValue];

        UINavigationController *viewController = [self viewControllerForSocialSourceType:socialSourceType];

        NSUInteger index = [self.socialViewControllers indexOfObject:viewController];
        PGSocialSource *socialSource = self.socialSources[index];
        [self updateMediaNavigationForViewController:viewController.viewControllers.lastObject socialSource:socialSource];

        [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        
        self.socialSourceType = socialSourceType;

        if (includeLogin) {
            if ([viewController.topViewController isKindOfClass:[PGLandingPageViewController class]]) {
                PGLandingPageViewController *landingPageViewController = (PGLandingPageViewController *) viewController.topViewController;
                [landingPageViewController performSelector:@selector(showLogin) withObject:nil afterDelay:1.0];
            }
        }
    }
}

- (void)enablePageControllerFunctionalityNotification:(NSNotification *)notification
{
    [self enableSwipe];
}

- (void)disablePageControllerFunctionalityNotification:(NSNotification *)notification
{
    [self disableSwipe];
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
    if (!self.navigationView) {
        self.navigationView = [PGMediaNavigation sharedInstance];
        self.navigationView.frame = self.view.bounds;
        self.navigationView.delegate = self;

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


#pragma mark - PGMediaNavigationDelegate

- (void)mediaNavigationDidPressMenuButton:(PGMediaNavigation *)mediaNav
{
    [self hideStatusBar];
    PGLandingPageViewController *vc = (PGLandingPageViewController *)([self currentNavigationController].viewControllers[0]);
    [vc.revealViewController revealToggle:self];
}

- (void)mediaNavigationDidPressFolderButton:(PGMediaNavigation *)mediaNav
{
    UINavigationController *navController = [self currentNavigationController];

    PGLandingPageViewController *landingPage = (PGLandingPageViewController *)navController.viewControllers[0];
    [landingPage showAlbums];
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
    self.isDraggingPage = NO;
    
    if (!completed) {
        return;
    }
    
    UINavigationController *navigationViewController = pageViewController.viewControllers.lastObject;
    UINavigationController *viewController = navigationViewController.viewControllers.lastObject;
    NSUInteger index = [self.socialViewControllers indexOfObject:navigationViewController];

    if (index != NSNotFound) {
        PGSocialSource *socialSource = self.socialSources[index];
        self.socialSourceType = socialSource.type;

        [self updateMediaNavigationForViewController:viewController socialSource:socialSource];
    }
}

- (void)updateMediaNavigationForViewController:(UIViewController *)viewController socialSource:(PGSocialSource *)socialSource
{
    if (self.isDraggingPage) {
        return;
    }

    self.navigationView.socialSource = socialSource;

    BOOL isShowingPhotoGallery = [viewController isKindOfClass:[HPPRSelectPhotoCollectionViewController class]];

    if (isShowingPhotoGallery) {
        [self.navigationView hideCameraButton];

        if (socialSource.hasFolders) {
            BOOL isShowingAlbumsSelector = ((PGLandingPageViewController *)self.currentNavigationController.viewControllers.firstObject).albumsViewController != nil;

            [self.navigationView showAlbumsDropDownButton];

            if (isShowingAlbumsSelector) {
                [self.navigationView hideGradientBar];
            } else {
                [self.navigationView showGradientBar];
            }
        }
    } else {
        [self.navigationView showGradientBar];
        [self.navigationView showCameraButton];
        [self.navigationView hideAlbumsDropDownButton];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    self.isDraggingPage = YES;
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
        index = ((index - 1) % self.socialSources.count);

        return self.socialViewControllers[index];
    }

    return nil;
}


#pragma mark - PGLandingPageViewControllerDelegate

- (void)landingPageViewController:(PGLandingPageViewController *)landingViewController didNavigateTo:(UIViewController *)viewController {
    NSUInteger index = [self.socialViewControllers indexOfObject:landingViewController.navigationController];

    if (index != NSNotFound) {
        PGSocialSource *socialSource = self.socialSources[index];
        self.socialSourceType = socialSource.type;

        [self updateMediaNavigationForViewController:viewController socialSource:socialSource];
    }
}

@end
