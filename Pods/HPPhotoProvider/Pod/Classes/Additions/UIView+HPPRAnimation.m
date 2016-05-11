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

#import "UIView+HPPRAnimation.h"

@implementation UIView (HPPRAnimation)

- (UIActivityIndicatorView *)HPPRAddSpinner
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [spinner startAnimating];
    
    [spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:spinner];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:spinner
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterX 
                                                              multiplier:1.0 
                                                                constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:spinner
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterY 
                                                              multiplier:1.0 
                                                                constant:0.0]];
    
    return spinner;
}

@end
