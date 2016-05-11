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

#import "Node+Fix.h"
#import <objc/runtime.h>
#import "Node.h"
#import "NodeList.h"
#import "NodeList+Mutable.h"

@implementation Node (Fix)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(removeChild:);
        SEL swizzledSelector = @selector(removeChildSecuencially:);
        
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

- (Node *)removeChildSecuencially:(Node *)oldChild
{
    for (Node *node in self.childNodes.internalArray) {
        if (node == oldChild) {
            [self.childNodes.internalArray removeObject:oldChild];
            return oldChild;
        }
        
        [node removeChild:oldChild];
    }
    
	return oldChild;
}

@end
