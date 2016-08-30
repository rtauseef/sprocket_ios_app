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

@implementation PGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Force the initialization of the analytics manager to start tracking crashes
    [PGAnalyticsManager sharedManager];

    [PGAppAppearance setupAppearance];
    
    [HPPR sharedInstance].instagramClientId = @"5db5d92b37f44ad89c5b620a2dc7081c";
    [HPPR sharedInstance].instagramRedirectURL = @"http://www8.hp.com/us/en/contact-hp/contact.html";
    
    [HPPR sharedInstance].flickrAppKey = @"48fe53f214de34251c7833fa1675d4b3";
    [HPPR sharedInstance].flickrAppSecret = @"8865a1b2f3742370";
    [HPPR sharedInstance].flickrAuthCallbackURL = @"hpsprocket://callback/flickr";
    
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
    
    MPPaper *paper = [[MPPaper alloc] initWithPaperSize:MPPaperSize2x3 paperType:MPPaperTypePhoto];
    NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionaryWithDictionary:[MP sharedInstance].lastOptionsUsed];
    [lastOptionsUsed setValue:paper.typeTitle forKey:kMPPaperTypeId];
    [lastOptionsUsed setValue:paper.sizeTitle forKey:kMPPaperSizeId];
    [lastOptionsUsed setValue:[NSNumber numberWithFloat:paper.width] forKey:kMPPaperWidthId];
    [lastOptionsUsed setValue:[NSNumber numberWithFloat:paper.height] forKey:kMPPaperHeightId];
    [lastOptionsUsed setValue:[NSNumber numberWithBool:NO] forKey:kMPBlackAndWhiteFilterId];
    [lastOptionsUsed setValue:[NSNumber numberWithInteger:1] forKey:kMPNumberOfCopies];
    
//    [lastOptionsUsed setValue:kMPPrinterDetailsNotAvailable forKey:kMPPrinterDisplayName];
//    [lastOptionsUsed setValue:kMPPrinterDetailsNotAvailable forKey:kMPPrinterDisplayLocation];
//    [lastOptionsUsed setValue:kMPPrinterDetailsNotAvailable forKey:kMPPrinterMakeAndModel];
    
    [MP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];

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
    [[HPPRFacebookLoginProvider sharedInstance] handleDidBecomeActive];
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PrintInstructions"];
    
    MPSupportAction *action1 = [[MPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"Get_Help_Print"] title:NSLocalizedString(@"How To", nil) viewController:navigationController];
    
    // NOTE: This link is not localized, only the english version is available
    MPSupportAction *action2 = [[MPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"Buy_Paper_Print"] title:NSLocalizedString(@"Buy Paper", nil) url:[NSURL URLWithString:@"http://store.hp.com/webapp/wcs/stores/servlet/us/en/pdp/ink--toner---paper/hp-social-media-snapshots-removable-sticky-photo-paper-25-sht-4-x-5-in"]];
    
    [MP sharedInstance].supportActions =  @[action1, action2];
}

@end
