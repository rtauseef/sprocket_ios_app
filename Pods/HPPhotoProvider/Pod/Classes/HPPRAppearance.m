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

#import "HPPRAppearance.h"
#import "UIColor+HPPRStyle.h"
#import "UIFont+HPPRStyle.h"

NSString * const kHPPRBackgroundColor = @"kHPPRBackgroundColor";
NSString * const kHPPRTableSeparatorColor = @"kHPPRTableSeparatorColor";

NSString * const kHPPRTintColor = @"kHPPRTintColor";
NSString * const kHPPRButtonTitleColorSelected = @"kHPPRButtonTitleColorSelected";
NSString * const kHPPRButtonTitleColorNormal = @"kHPPRButtonTitleColorNormal";
NSString * const kHPPRPrimaryLabelFont = @"kHPPRPrimaryLabelFont";
NSString * const kHPPRPrimaryLabelColor = @"kHPPRPrimaryLabelColor";
NSString * const kHPPRSecondaryLabelFont = @"kHPPRSecondaryLabelFont";
NSString * const kHPPRSecondaryLabelColor = @"kHPPRSecondaryLabelColor";
NSString * const kHPPRGridViewOnIcon = @"kHPPRGridViewOnIcon";
NSString * const kHPPRGridViewOffIcon = @"kHPPRGridViewOffIcon";
NSString * const kHPPRListViewOnIcon = @"kHPPRListViewOnIcon";
NSString * const kHPPRListViewOffIcon = @"kHPPRListViewOffIcon";
NSString * const kHPPRFilterButtonLeftOnIcon = @"kHPPRFilterButtonLeftOnIcon";
NSString * const kHPPRFilterButtonLeftOffIcon = @"kHPPRFilterButtonLeftOffIcon";
NSString * const kHPPRFilterButtonRightOnIcon = @"kHPPRFilterButtonRightOnIcon";
NSString * const kHPPRFilterButtonRightOffIcon = @"kHPPRFilterButtonRightOffIcon";
NSString * const kHPPRLoadingCellBackgroundColor = @"kHPPRLoadingCellBackgroundColor";

@implementation HPPRAppearance

- (NSDictionary *)settings
{
    if (nil == _settings) {
        _settings = [self defaultSettings];
    }
    
    return _settings;
}

- (NSDictionary *)defaultSettings
{
    _settings = @{
                  kHPPRBackgroundColor:            [UIColor whiteColor],
                  kHPPRTintColor:                  [UIColor HPPRBlueColor],
                  kHPPRButtonTitleColorSelected:   [UIColor whiteColor],
                  kHPPRButtonTitleColorNormal:     [UIColor HPPRBlueColor],
                  kHPPRPrimaryLabelFont:           [UIFont HPPRSimplifiedRegularFontWithSize:17.0f],
                  kHPPRPrimaryLabelColor:          [UIColor blackColor],
                  kHPPRSecondaryLabelFont:         [UIFont HPPRSimplifiedLightFontWithSize:12.0f],
                  kHPPRSecondaryLabelColor:        [UIColor blackColor],
                  kHPPRTableSeparatorColor:        [UIColor colorWithRed:0.783922 green:0.780392 blue:0.8 alpha:1.0],
                  kHPPRGridViewOnIcon:             [UIImage imageNamed:@"HPPRGridViewOn"],
                  kHPPRGridViewOffIcon:            [UIImage imageNamed:@"HPPRGridViewOff"],
                  kHPPRListViewOnIcon:             [UIImage imageNamed:@"HPPRListViewOn"],
                  kHPPRListViewOffIcon:            [UIImage imageNamed:@"HPPRListViewOff"],
                  kHPPRFilterButtonLeftOnIcon:     [UIImage imageNamed:@"HPPRFilterButtonLeftOn"],
                  kHPPRFilterButtonLeftOffIcon:    [UIImage imageNamed:@"HPPRFilterButtonLeftOff"],
                  kHPPRFilterButtonRightOnIcon:    [UIImage imageNamed:@"HPPRFilterButtonRightOn"],
                  kHPPRFilterButtonRightOffIcon:   [UIImage imageNamed:@"HPPRFilterButtonRightOff"],
                  kHPPRLoadingCellBackgroundColor: [UIColor colorWithRed:0xDB/255.0f  green:0xEA/255.0f  blue:0xF8/255.0f alpha:1.0f]
                  };
    
    return _settings;
}

@end
