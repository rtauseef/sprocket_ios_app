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

#import "AVPlayerViewController+Fullscreen.h"

@implementation AVPlayerViewController (Fullscreen)

-(void)goFullscreen {
    SEL fsSelector = NSSelectorFromString(@"_transitionToFullScreenViewControllerAnimated:completionHandler:");
    if ([self respondsToSelector:fsSelector]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:fsSelector]];
        [inv setSelector:fsSelector];
        [inv setTarget:self];
        BOOL animated = YES;
        id completionBlock = nil;
        [inv setArgument:&(animated) atIndex:2];
        [inv setArgument:&(completionBlock) atIndex:3];
        [inv invoke];
    }
}

@end
