//
//  AVPlayerViewController+Fullscreen.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/16/17.
//  Copyright © 2017 HP. All rights reserved.
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
