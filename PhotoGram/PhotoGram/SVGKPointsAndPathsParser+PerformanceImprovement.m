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

#import "SVGKPointsAndPathsParser+PerformanceImprovement.h"
#import <objc/runtime.h>

@implementation SVGKPointsAndPathsParser (PerformanceImprovement)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = object_getClass((id)[self class]);
        
        SEL originalSelector = @selector(readWhitespace:);
        SEL swizzledSelector = @selector(ignore_readWhitespace:);
        
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

// NOTE:
/*
For what I understood of the library code, the readWhitespace method commented basically ignores the line break, spaces and tabs chars and moves the location pointer to the following valid character. That method is been called thousands of times during the parsing.

This is the code inside readWhitespace:

[scanner scanCharactersFromSet:[NSString stringWithFormat:@"%c%c%c%c", 0x20, 0x9, 0xD, 0xA] intoString:NULL];

Passing NULL in the second parameter simple moves the location pointer inside the scanner. The default characters skipped in the NSScanner are the line break and space. But we can add the tab calling only once the following method after the scanner is created:

[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%c%c%c%c", 0x20, 0x9, 0xD, 0xA]]];

I tested adding setCharactersToBeSkipped and works good. Also works good without calling setCharactersToBeSkipped, probably the tab is not affecting the scanner. So I'm not gonna add it for now.
*/
 
 + (void)ignore_readWhitespace:(NSScanner *)scanner
{
    
}

@end