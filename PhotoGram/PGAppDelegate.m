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
#import "PGAppDelegate.h"
#import "PGAppAppearance.h"
#import "PGAnalyticsManager.h"
#import "PGLogger.h"
#import "PGBadgeNumberManager.h"
#import "PGSVGResourceManager.h"

@implementation PGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Force the initialization of the analytics manager to start tracking crashes
    [PGAnalyticsManager sharedManager];

    [PGBadgeNumberManager sharedManager];

    [PGAppAppearance setupAppearance];
    
    [HPPR sharedInstance].instagramClientId = @"5db5d92b37f44ad89c5b620a2dc7081c";
    [HPPR sharedInstance].instagramRedirectURL = @"http://www8.hp.com/us/en/contact-hp/contact.html";
    
    [HPPR sharedInstance].flickrAppKey = @"3a1548d1e080969f1d719be81093bb51";
    [HPPR sharedInstance].flickrAppSecret = @"0007db25be2ff877";
    [HPPR sharedInstance].flickrAuthCallbackURL = @"hpsms://callback/flickr";
    
    [self initializePrintPod];
    
    // Check if the app was opened by local notification
    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        PGLogInfo(@"App starts to run because of a notification");
        self.openFromNotification = YES;
    }

    [[PGLogger sharedInstance] configureLogging];
   
    PGLogInfo(@"%@", [NSBundle mainBundle]);
   
    // For now, unzip all .hpc files each time the app starts
    [PGSVGResourceManager unzipAllHpcFiles:TRUE];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
    
    if ([url.scheme isEqual:@"hpsms"]) {
        return [[HPPRFlickrLoginProvider sharedInstance] handleOpenURL:url sourceApplication:sourceApplication];
    } else {
        return [[HPPRFacebookLoginProvider sharedInstance] handleOpenURL:url sourceApplication:sourceApplication];
    }
}

#pragma mark - MP object initialization

- (void)initializePrintPod
{
    [MP sharedInstance].handlePrintMetricsAutomatically = NO;
    [MP sharedInstance].uniqueDeviceIdPerApp = NO;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PrintInstructions"];
    
    MPSupportAction *action1 = [[MPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"LearnMore"] title:NSLocalizedString(@"Print Instructions", nil) viewController:navigationController];
    
    // NOTE: This link is not localized, only the english version is available
    MPSupportAction *action2 = [[MPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"BuyNow"] title:NSLocalizedString(@"Buy sticker pack", nil) url:[NSURL URLWithString:@"http://store.hp.com/webapp/wcs/stores/servlet/us/en/pdp/ink--toner---paper/hp-social-media-snapshots-removable-sticky-photo-paper-25-sht-4-x-5-in"]];
    
    [MP sharedInstance].supportActions =  @[action1, action2];
}

@end
