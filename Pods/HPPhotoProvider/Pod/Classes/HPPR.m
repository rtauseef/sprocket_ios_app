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

#import "HPPR.h"

NSString * const kHPPRTrackableScreenNameKey = @"screen-name";
NSString * const kHPPRProviderName = @"provider";

@implementation HPPR

+ (HPPR *)sharedInstance
{
    static dispatch_once_t once;
    static HPPR *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPR alloc] init];
        sharedInstance.appearance = [[HPPRAppearance alloc] init];
    });
    return sharedInstance;
}

- (UIViewController *)keyWindowTopMostController
{
    
#ifndef TARGET_IS_EXTENSION
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
#else
    UIViewController *topController = self.extensionController;
#endif
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if ([topController isKindOfClass:[UINavigationController class]]) {
        topController = ((UINavigationController *)topController).topViewController;
    }
    
    return topController;
}

@end
