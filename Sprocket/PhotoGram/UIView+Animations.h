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

#import <UIKit/UIKit.h>

@interface UIView (Animations)

+ (void)textEditionTabBarAnimateWithAnimations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

- (void)animateConstraintsWithDuration:(NSTimeInterval)duration constraints:(void (^)(void))constraints;
- (void)animateConstraintsWithDuration:(NSTimeInterval)duration constraints:(void (^)(void))constraints completion:(void (^)(BOOL))completion;

- (UIActivityIndicatorView *)addSpinner;

@end
