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

#import <HPPR.h>
#import <MP.h>
#import <HPPRFacebookLoginProvider.h>
#import <HPPRFlickrPhotoProvider.h>
#import <HPPRFlickrLoginProvider.h>
#import <HPPRInstagramPhotoProvider.h>
#import <DBChooser/DBChooser.h>
#import <MPBTPrintManager.h>

#import "AirshipKit.h"
#import "PGAppDelegate.h"
#import "PGAppAppearance.h"
#import "PGAnalyticsManager.h"
#import "PGLogger.h"
#import "PGRevealViewController.h"
#import "PGLandingSelectorPageViewController.h"
#import "UIViewController+Trackable.h"
#import "PGSecretKeeper.h"

static const NSInteger connectionDefaultValue = -1;
static NSUInteger const kPGAppDelegatePrinterConnectivityCheckInterval = 1;

@interface PGAppDelegate()

@property (strong, nonatomic) NSTimer *sprocketConnectivityTimer;
@property (assign, nonatomic) NSInteger lastConnectedValue;
@property (assign, nonatomic) BOOL menuShowing;

@end

@implementation PGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Force the initialization of the analytics manager to start tracking crashes
    [PGAnalyticsManager sharedManager];

    [PGAppAppearance setupAppearance];
    
    [HPPR sharedInstance].instagramClientId = [[PGSecretKeeper sharedInstance] secretForEntry:kSecretKeeperEntryInstagramClientId];
    [HPPR sharedInstance].instagramRedirectURL = @"http://www8.hp.com/us/en/contact-hp/contact.html";
    
    [HPPR sharedInstance].flickrAppKey = [[PGSecretKeeper sharedInstance] secretForEntry:kSecretKeeperEntryFlickrAppKey];
    [HPPR sharedInstance].flickrAppSecret = [[PGSecretKeeper sharedInstance] secretForEntry:kSecretKeeperEntryFlickrAppSecret];
    [HPPR sharedInstance].flickrAuthCallbackURL = @"hpsprocket://callback/flickr";
    
    [HPPR sharedInstance].qzoneAppId = [[PGSecretKeeper sharedInstance] secretForEntry:kSecretKeeperEntryQZoneAppId];
    [HPPR sharedInstance].qzoneRedirectURL = @"www.qq.com";
    
    [self initializePrintPod];
    
    [[HPPRFacebookLoginProvider sharedInstance] handleApplication:application didFinishLaunchingWithOptions:launchOptions];

    // Check if the app was opened by local notification
    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        PGLogInfo(@"App starts to run because of a notification");
        self.openFromNotification = YES;
    }

    [[PGLogger sharedInstance] configureLogging];
   
    PGLogInfo(@"%@", [NSBundle mainBundle]);
   
    self.window.backgroundColor = [UIColor greenColor];
    
    self.lastConnectedValue = connectionDefaultValue;
    self.menuShowing = NO;

    [self initializeUAirship];

    [[MPBTPrintManager sharedInstance] resumePrintQueue:nil];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.sprocketConnectivityTimer invalidate];
    self.sprocketConnectivityTimer = nil;
    self.lastConnectedValue = connectionDefaultValue;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MENU_CLOSED_NOTIFICATION object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[HPPRFacebookLoginProvider sharedInstance] handleDidBecomeActive];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];

    [self checkSprocketPrinterConnectivity:nil];
    
    self.sprocketConnectivityTimer = [NSTimer scheduledTimerWithTimeInterval:kPGAppDelegatePrinterConnectivityCheckInterval target:self selector:@selector(checkSprocketPrinterConnectivity:) userInfo:nil repeats:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateInactive) {
        PGLogInfo(@"Receive local notification while the app was inactive and the user tap in the notification (instead of the action).");
        [[MP sharedInstance] handleNotification:notification];
    } else if (application.applicationState == UIApplicationStateActive) {
        PGLogInfo(@"Receive local notification while the app was active.");
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    PGLogInfo(@"Action %@", identifier);
    
    [[MP sharedInstance] handleNotification:notification action:identifier];
    
    completionHandler();
}

#pragma mark - URL handler

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[DBChooser defaultChooser] handleOpenURL:url]) {
        // This was a Chooser response and handleOpenURL automatically ran the completion block
        return YES;
    }
    
    if ([url.scheme isEqual:@"hpsprocket"]) {
        return [[HPPRFlickrLoginProvider sharedInstance] handleApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    } else {
        return [[HPPRFacebookLoginProvider sharedInstance] handleApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
}

#pragma mark - MP object initialization

- (void)initializePrintPod
{
    [MP sharedInstance].handlePrintMetricsAutomatically = NO;
    [MP sharedInstance].uniqueDeviceIdPerApp = NO;
    [MP sharedInstance].defaultPaper = [[MPPaper alloc] initWithPaperSize:MPPaperSize2x3 paperType:MPPaperTypePhoto];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PrintInstructions"];
    
    MPSupportAction *action1 = [[MPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"Get_Help_Print"] title:NSLocalizedString(@"How To", nil) viewController:navigationController];
    
    // NOTE: This link is not localized, only the english version is available
    MPSupportAction *action2 = [[MPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"Buy_Paper_Print"] title:NSLocalizedString(@"Buy Paper", nil) url:[NSURL URLWithString:@"http://store.hp.com/webapp/wcs/stores/servlet/us/en/pdp/ink--toner---paper/hp-social-media-snapshots-removable-sticky-photo-paper-25-sht-4-x-5-in"]];
    
    [MP sharedInstance].supportActions =  @[action1, action2];
}

- (void)initializeUAirship
{
    /*
    // Starting Urban Airship Services
    // Set log level for debugging config loading (optional)
    // It will be set to the value in the loaded config upon takeOff
    [UAirship setLogLevel:UALogLevelTrace];
    
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    // or set runtime properties here.
    UAConfig *config = [UAConfig defaultConfig];
    
    // Call takeOff (which creates the UAirship singleton)
    [UAirship takeOff:config];
    
    // Print out the application configuration for debugging (optional)
    UA_LDEBUG(@"Config:\n%@", [config description]);
    
    // Set the icon badge to zero on startup (optional)
    [[UAirship push] resetBadge];
    
    // Set the notification types required for the app (optional). This value defaults
    // to badge, alert and sound, so it's only necessary to set it if you want
    // to add or remove types.
    //    [UAirship push].userNotificationTypes = (UIUserNotificationTypeAlert |
    //                                        UIUserNotificationTypeBadge |
    //                                        UIUserNotificationTypeSound);
    */
}


#pragma mark - Notifications

- (void)handleMenuOpenedNotification:(NSNotification *)notification
{
    self.menuShowing = YES;
}

- (void)handleMenuClosedNotification:(NSNotification *)notification
{
    self.menuShowing = NO;
}

#pragma mark - sprocket connectivity and reporting

- (void)checkSprocketPrinterConnectivity:(NSTimer *)timer
{
    NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
    NSInteger currentlyConnected = (numberOfPairedSprockets > 0);
    
    // Only record changes to printer connectivity
    if (connectionDefaultValue != self.lastConnectedValue  &&
        self.lastConnectedValue != currentlyConnected) {
        PGRevealViewController *revealController = (PGRevealViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        
        UIViewController *rootViewController = revealController.frontViewController;
        
        if (self.menuShowing) {
            rootViewController = revealController.rearViewController;
        }
        
        UIViewController *topViewController = [self topViewController:rootViewController];
        NSString *name = topViewController.trackableScreenName;
        if (nil == name) {
            name = [NSString stringWithFormat:@"%@", [topViewController class]];
        }
        
        [[PGAnalyticsManager sharedManager] trackPrinterConnected:(BOOL)currentlyConnected screenName:name];
    }
    
    self.lastConnectedValue = currentlyConnected;
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
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

@end
