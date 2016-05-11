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
#import <UIKit/UIKit.h>
#import "UIFont+HPPRStyle.h"
#import "HPPR.h"

@implementation UIFont (HPPRStyle)

+ (UIFont *)HPPRSimplifiedRegularFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HPSimplified-Regular" size:size];
}

+ (UIFont *)HPPRSimplifiedLightFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HPSimplified-Light" size:size];
}

+ (UIFont *)HPPRNavigationBarButtonItemFont
{
    return [UIFont HPPRSimplifiedLightFontWithSize:16.0f];
}

@end
