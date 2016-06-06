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

#import <objc/runtime.h>
#import "UIViewController+Trackable.h"
#import "PGAnalyticsManager.h"
#import <Crashlytics/Crashlytics.h>

static void * trackableScreenNamePropertyKey = &trackableScreenNamePropertyKey;

@implementation UIViewController (Trackable)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(trackable_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

- (void)trackable_viewWillAppear:(BOOL)animated
{
    [self trackable_viewWillAppear:animated];
    
    if (self.trackableScreenName) {
        [[PGAnalyticsManager sharedManager] trackScreenViewEvent:self.trackableScreenName];
        [Crashlytics setObjectValue:self.trackableScreenName forKey:@"Screen Name"];
    }
    
    PGLogInfo(@"%@ viewWillAppear", [self class]);
}

#pragma mark - Getter & Setters

- (NSString *)trackableScreenName
{
    return objc_getAssociatedObject(self, trackableScreenNamePropertyKey);
}

- (void)setTrackableScreenName:(NSString *)trackableScreenName
{
    objc_setAssociatedObject(self, trackableScreenNamePropertyKey, trackableScreenName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


@end
