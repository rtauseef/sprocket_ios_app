//
//  PGDeepLinkLauncher.h
//  Sprocket
//
//  Created by Susy Snowflake on 3/9/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGWebViewerViewController.h"

extern NSString * const kSurveyURL;
extern NSString * const kSurveyNotifyURL;

@interface PGDeepLinkLauncher : NSObject

+ (PGDeepLinkLauncher *)sharedInstance;

@property (assign, nonatomic) BOOL menuShowing;


+ (void)deepLink:(NSString *)location;
+ (UIViewController *)currentTopViewController;

+ (UINavigationController *)surveyNavController:(id<PGWebViewerViewControllerDelegate>)delegate;
+ (UIViewController *)howToAndHelpViewController;
+ (void)sendEmail:(UIViewController *)launchingPoint;
+ (void)openSettings;

@end
