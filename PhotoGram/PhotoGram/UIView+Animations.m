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

#import "UIView+Animations.h"

@implementation UIView (Animations)

+ (void)textEditionTabBarAnimateWithAnimations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:animations
                     completion:completion];
}

- (void)animateConstraintsWithDuration:(NSTimeInterval)duration constraints:(void (^)(void))constraints {
	[self animateConstraintsWithDuration:duration constraints:constraints completion:nil];
}

- (void)animateConstraintsWithDuration:(NSTimeInterval)duration constraints:(void (^)(void))constraints completion:(void (^)(BOOL finished))completion {
	NSParameterAssert(constraints);
	
	[self layoutIfNeeded];
	
	constraints();
	
	[UIView animateWithDuration:duration
					 animations:^{
						 [self layoutIfNeeded];
					 }
					 completion:completion];
}

- (UIActivityIndicatorView *)addSpinner
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [spinner startAnimating];
    
    [spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:spinner];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|[spinner]|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(spinner)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|[spinner]|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(spinner)]];
    
    return spinner;
}

@end
