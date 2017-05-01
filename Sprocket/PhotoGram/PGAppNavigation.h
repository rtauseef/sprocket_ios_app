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

#import <Foundation/Foundation.h>
#import "PGWebViewerViewController.h"

extern NSString * const kSurveyURL;
extern NSString * const kSurveyNotifyURL;

@interface PGAppNavigation : NSObject

+ (PGAppNavigation *)sharedInstance;

@property (assign, nonatomic) BOOL menuShowing;


+ (void)deepLink:(NSString *)location;
+ (UIViewController *)currentTopViewController;

+ (UINavigationController *)surveyNavController:(id<PGWebViewerViewControllerDelegate>)delegate;
+ (UIViewController *)howToAndHelpViewController;
+ (void)sendEmail:(UIViewController *)launchingPoint;
+ (void)openSettings;

@end
