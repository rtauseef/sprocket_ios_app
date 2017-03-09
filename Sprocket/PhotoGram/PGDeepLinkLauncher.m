//
//  PGDeepLinkLauncher.m
//  Sprocket
//
//  Created by Susy Snowflake on 3/9/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGDeepLinkLauncher.h"
#import "UIViewController+Trackable.h"
#import "PGRevealViewController.h"
#import "PGLandingMainPageViewController.h"
#import "PGLandingSelectorPageViewController.h"
#import "PGPreviewViewController.h"
#import "PGSocialSource.h"

#import "AirshipKit.h"

// Needed to suppress iOS 7 check for UIApplicationOpenSettingsURLString
#pragma GCC diagnostic ignored "-Wtautological-pointer-compare"

NSString * const kSurveyURL = @"https://www.surveymonkey.com/r/Q99S6P5";
NSString * const kSurveyNotifyURL = @"www.surveymonkey.com/r/close-window";

@interface PGDeepLinkLauncher()<MFMailComposeViewControllerDelegate>
    @property (weak, nonatomic) UIViewController *mailLaunchingPoint;
@end

@implementation PGDeepLinkLauncher

+ (PGDeepLinkLauncher *)sharedInstance
{
    static dispatch_once_t once;
    static PGDeepLinkLauncher *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGDeepLinkLauncher alloc] init];
    });
    return sharedInstance;
}

+ (void)deepLink:(NSString *)location
{
    NSLog(@"location: %@", location);
    if ([location isEqualToString:@"landingPage"]) {
        [PGDeepLinkLauncher goToLandingPage];
    } else if ([location isEqualToString:@"howToAndHelp"]) {
        UIViewController *viewController = [PGDeepLinkLauncher howToAndHelpViewController];
        [[PGDeepLinkLauncher currentTopViewController] presentViewController:viewController animated:YES completion:nil];
    } else if ([location isEqualToString:@"flickr"]) {
        [PGDeepLinkLauncher goToSocialSource:PGSocialSourceTypeFlickr];
    } else if ([location isEqualToString:@"instagram"]) {
        [PGDeepLinkLauncher goToSocialSource:PGSocialSourceTypeInstagram];
    } else if ([location isEqualToString:@"facebook"]) {
        [PGDeepLinkLauncher goToSocialSource:PGSocialSourceTypeFacebook];
    } else if ([location isEqualToString:@"qzone"]) {
        [PGDeepLinkLauncher goToSocialSource:PGSocialSourceTypeQzone];
    } else if ([location isEqualToString:@"pitu"]) {
        [PGDeepLinkLauncher goToSocialSource:PGSocialSourceTypePitu];
    } else if ([location isEqualToString:@"cameraRoll"]) {
        [PGDeepLinkLauncher goToSocialSource:PGSocialSourceTypeLocalPhotos];
    } else if ([location isEqualToString:@"appSettings"]) {
        [PGDeepLinkLauncher openSettings];
    } else if ([location isEqualToString:@"emailFeedback"]) {
        [PGDeepLinkLauncher sendEmail:[self currentTopViewController]];
    } else if ([location isEqualToString:@"camera"]) {
        [PGDeepLinkLauncher goToCamera];
    }
}

+ (UINavigationController *)surveyNavController:(id<PGWebViewerViewControllerDelegate>)delegate
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewerNavigationController"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    PGWebViewerViewController *webViewerViewController = (PGWebViewerViewController *)navigationController.topViewController;
    webViewerViewController.trackableScreenName = @"Take Our Survey Screen";
    webViewerViewController.url = kSurveyURL;
    webViewerViewController.notifyUrl = kSurveyNotifyURL;
    webViewerViewController.delegate = delegate;
    
    return navigationController;
}

+ (UIViewController *)howToAndHelpViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PrintInstructions"];
    
    return viewController;
}

+ (void)sendEmail:(UIViewController *)launchingPoint
{
    [PGDeepLinkLauncher sharedInstance].mailLaunchingPoint = launchingPoint;
    
    if ([MFMailComposeViewController canSendMail]) {
        // Use the first six alpha-numeric characters in the device id as an identifier in the subject line
        NSString *deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
        NSCharacterSet *removeCharacters = [NSCharacterSet alphanumericCharacterSet].invertedSet;
        NSArray *remainingNumbers = [deviceId componentsSeparatedByCharactersInSet:removeCharacters];
        deviceId = [remainingNumbers componentsJoinedByString:@""];
        if( deviceId.length >= 6 ) {
            deviceId = [deviceId substringToIndex:6];
        }
        
        NSString *subjectLine = NSLocalizedString(@"Feedback on sprocket for iOS (Record Locator: %@)", @"Subject of the email send to technical support");
        subjectLine = [NSString stringWithFormat:subjectLine, deviceId];
        
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.trackableScreenName = @"Feedback Screen";
        [mailComposeViewController.navigationBar setTintColor:[UIColor whiteColor]];
        mailComposeViewController.mailComposeDelegate = [PGDeepLinkLauncher sharedInstance];
        [mailComposeViewController setSubject:subjectLine];
        [mailComposeViewController setMessageBody:@"" isHTML:NO];
        [mailComposeViewController setToRecipients:@[@"hpsnapshots@hp.com"]];
        
        [[PGDeepLinkLauncher sharedInstance].mailLaunchingPoint presentViewController:mailComposeViewController animated:YES completion:^{
            // This is a workaround to set the text white in the status bar (otherwise by default would be black)
            // http://stackoverflow.com/questions/18945390/mfmailcomposeviewcontroller-in-ios-7-statusbar-are-black
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:NSLocalizedString(@"You don’t have any account configured to send emails.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - forced app navigation

+ (PGRevealViewController *)revealController
{
    PGRevealViewController *revealController = (PGRevealViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    return revealController;
}

+ (UINavigationController *)frontNavController
{
    PGRevealViewController *revealController = [PGDeepLinkLauncher revealController];
    
    UINavigationController *frontNavController = nil;
    
    if ([revealController.frontViewController isKindOfClass:[UINavigationController class]]) {
        frontNavController = (UINavigationController *)revealController.frontViewController;
    } else {
        PGLogError(@"Front view controller is not a UINavigationController!");
    }
    
    return frontNavController;
}

+ (PGLandingMainPageViewController *)landingPage
{
    PGLandingMainPageViewController *landingPage = nil;
    
    UINavigationController *frontNavController = [PGDeepLinkLauncher frontNavController];
    
    if (frontNavController  &&  [frontNavController.viewControllers count]) {
        if ([frontNavController.viewControllers[0] isKindOfClass:[PGLandingMainPageViewController class]]) {
            landingPage = frontNavController.viewControllers[0];
        }
    }
    
    if (nil == landingPage) {
        PGLogError(@"Unexpected landing page!");
    }
    
    return landingPage;
}

+ (void)goToCamera
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewControllerCamera = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    
    [[PGDeepLinkLauncher currentTopViewController] presentViewController:previewViewControllerCamera animated:YES completion:nil];
}

+ (void)goToSocialSource:(PGSocialSourceType)type
{
    PGLandingMainPageViewController *landingPage = [PGDeepLinkLauncher landingPage];
    
    [self goToLandingPage];
    [landingPage goToSocialSourcePage:type sender:[PGDeepLinkLauncher sharedInstance]];
}

+ (void)goToLandingPage
{
    [[UAirship defaultMessageCenter] dismiss:YES];
    PGRevealViewController *revealController = [self revealController];
    
    UINavigationController *rootViewController = [self frontNavController];
    
    if ([PGDeepLinkLauncher sharedInstance].menuShowing) {
        [revealController revealToggle:self];
        [revealController.rearViewController dismissViewControllerAnimated:YES completion:^{
        }];
    }
    
    [rootViewController popToRootViewControllerAnimated:NO];
}

+ (void)openSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

+ (UIViewController *)currentTopViewController
{
    PGRevealViewController *revealController =[self revealController];
    
    UIViewController *rootViewController = [self frontNavController];
    
    if ([PGDeepLinkLauncher sharedInstance].menuShowing) {
        rootViewController = revealController.rearViewController;
    }
    
    UIViewController *topViewController = [self topViewController:rootViewController];
    
    return topViewController;
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    UIViewController *topController = nil;
    
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)rootViewController;
        UIViewController *lastViewController = [[navController viewControllers] lastObject];
        topController = [self topViewController:lastViewController];
    } else if ([rootViewController isKindOfClass:[PGLandingSelectorPageViewController class]]) {
        PGLandingSelectorPageViewController *pageController = (PGLandingSelectorPageViewController *)rootViewController;
        UINavigationController *displayedController = [pageController currentNavigationController];
        UIViewController *lastViewController = [[displayedController viewControllers] lastObject];
        topController = [self topViewController:lastViewController];
    } else {
        UIViewController *presentedController = rootViewController.presentedViewController;
        if (nil != presentedController) {
            topController = [self topViewController:presentedController];
        } else {
            topController = rootViewController;
        }
    }
    
    return topController;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [[PGDeepLinkLauncher sharedInstance].mailLaunchingPoint dismissViewControllerAnimated:YES completion:NULL];
    [PGDeepLinkLauncher sharedInstance].mailLaunchingPoint = nil;
}

@end
