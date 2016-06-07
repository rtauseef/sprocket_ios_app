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

@interface UIFont (Style)

+ (UIFont *)HPSimplifiedRegularFontWithSize:(CGFloat)size;
+ (UIFont *)HPSimplifiedLightFontWithSize:(CGFloat)size;
+ (UIFont *)HPSimplifiedBoldFontWithSize:(CGFloat)size;
+ (CGFloat)HPDefaultCardFontSize;
+ (UIFont *)HPNavigationBarTitleFont;
+ (UIFont *)HPNavigationBarButtonItemFont;
+ (UIFont *)HPCoachMarkLabelFont;
+ (UIFont *)HPCategoryTitleFont;
+ (UIFont *)HPPaperSizeLabelFont;
+ (NSArray *)HPTextFonts;
- (float)minFontSize;

@end
