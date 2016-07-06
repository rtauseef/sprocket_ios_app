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

extern NSString * const kHPPRBackgroundColor = @"kHPPRBackgroundColor";
extern NSString * const kHPPRTableSeparatorColor = @"kHPPRTableSeparatorColor";

extern NSString * const kHPPRTintColor = @"kHPPRTintColor";
extern NSString * const kHPPRButtonTitleColorSelected = @"kHPPRButtonTitleColorSelected";
extern NSString * const kHPPRButtonTitleColorNormal = @"kHPPRButtonTitleColorNormal";
extern NSString * const kHPPRPrimaryLabelFont = @"kHPPRPrimaryLabelFont";
extern NSString * const kHPPRPrimaryLabelColor = @"kHPPRPrimaryLabelColor";
extern NSString * const kHPPRSecondaryLabelFont = @"kHPPRSecondaryLabelFont";
extern NSString * const kHPPRSecondaryLabelColor = @"kHPPRSecondaryLabelColor";
extern NSString * const kHPPRGridViewOnIcon = @"kHPPRGridViewOnIcon";
extern NSString * const kHPPRGridViewOffIcon = @"kHPPRGridViewOffIcon";
extern NSString * const kHPPRListViewOnIcon = @"kHPPRListViewOnIcon";
extern NSString * const kHPPRListViewOffIcon = @"kHPPRListViewOffIcon";
extern NSString * const kHPPRFilterButtonLeftOnIcon = @"kHPPRFilterButtonLeftOnIcon";
extern NSString * const kHPPRFilterButtonLeftOffIcon = @"kHPPRFilterButtonLeftOffIcon";
extern NSString * const kHPPRFilterButtonRightOnIcon = @"kHPPRFilterButtonRightOnIcon";
extern NSString * const kHPPRFilterButtonRightOffIcon = @"kHPPRFilterButtonRightOffIcon";
extern NSString * const kHPPRLoadingCellBackgroundColor = @"kHPPRLoadingCellBackgroundColor";

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
    NSString *regularFont = @"HelveticaNeue";
    NSString *lightFont   = @"HelveticaNeue-Medium";
    
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
