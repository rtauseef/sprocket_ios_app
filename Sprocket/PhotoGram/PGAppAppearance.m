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

#import <MP.h>
#import <HPPR.h>
#import "PGAppAppearance.h"
#import "UIFont+Style.h"
#import "UIColor+Style.h"
#import "UIColor+HexString.h"

#undef SHOW_AVAILABLE_FONTS

static NSString *PGAppAppearanceRegularFont = @"HPSimplified-Regular";
static NSString *PGAppAppearanceLightFont   = @"HPSimplified-Light";

@implementation PGAppAppearance

+ (void)setupAppearance
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont HPNavigationBarTitleFont]}];
    [[UINavigationBar appearance] setBarTintColor:[PGAppAppearance navBarColor]];
    
    [[UISwitch appearance] setOnTintColor:[UIColor HPBlueColor]];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont HPSimplifiedRegularFontWithSize:16.0f]} forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"Back"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"Back"]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont HPSimplifiedLightFontWithSize:14.0f]} forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0xB9/255.0f green:0xB8/255.0f blue:0xBB/255.0f alpha:1.0f], NSFontAttributeName:[UIFont HPSimplifiedLightFontWithSize:14.0f]} forState:UIControlStateNormal];
    
    [[UILabel appearanceWhenContainedIn:[UITableViewCell class], nil] setTextColor:[UIColor colorWithHexString:@"333333"]];
    [[UILabel appearanceWhenContainedIn:[UITableViewCell class], nil] setFont:[UIFont HPSimplifiedLightFontWithSize:18.0f]];
    
    [PGAppAppearance setPrintOptions];
    
#ifdef SHOW_AVAILABLE_FONTS
    
    NSMutableArray *fontNames = [[NSMutableArray alloc] init];
    NSArray *fontFamilyNames = [UIFont familyNames];
    
    for (NSString *familyName in fontFamilyNames) {
        NSLog(@"Font Family Name = %@", familyName);
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        
        NSLog(@"Font Names = %@", fontNames);
        
        [fontNames addObjectsFromArray:names];
    }
    
#endif
}

+ (NSDictionary *)mpAppearanceSettings
{
    
    return @{// Background
             kMPGeneralBackgroundColor:             [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
             kMPGeneralBackgroundPrimaryFont:       [UIFont fontWithName:PGAppAppearanceLightFont size:22],
             kMPGeneralBackgroundPrimaryFontColor:   [UIColor colorWithRed:77.0F/255.0F green:77.0F/255.0F blue:77.0F/255.0F alpha:1.0F],
             kMPGeneralBackgroundSecondaryFont:     [UIFont fontWithName:PGAppAppearanceRegularFont size:17],
             kMPGeneralBackgroundSecondaryFontColor:[UIColor colorWithRed:117.0F/255.0F green:118.0F/255.0F blue:120.0F/255.0F alpha:1.0F],
             kMPGeneralTableSeparatorColor:         [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
             
             // Selection Options
             kMPSelectionOptionsBackgroundColor:         [PGAppAppearance navBarColor],
             kMPSelectionOptionsPrimaryFont:             [UIFont fontWithName:PGAppAppearanceLightFont size:16],
             kMPSelectionOptionsPrimaryFontColor:        [UIColor colorWithRed:0x223/255.0F green:0x224/255.0F blue:0x227/255.0F alpha:1.0F],
             kMPSelectionOptionsSecondaryFont:           [UIFont fontWithName:PGAppAppearanceLightFont size:16],
             kMPSelectionOptionsSecondaryFontColor:      [UIColor colorWithRed:0x223/255.0F green:0x224/255.0F blue:0x227/255.0F alpha:1.0F],
             kMPSelectionOptionsLinkFont:                [UIFont fontWithName:PGAppAppearanceLightFont size:16],
             kMPSelectionOptionsLinkFontColor:           [UIColor colorWithRed:0x255/255.0F green:0x255/255.0F blue:0x255/255.0F alpha:1.0F],
             kMPSelectionOptionsDisclosureIndicatorImage:[UIImage imageNamed:@"MPArrow"],
             kMPSelectionOptionsCheckmarkImage:          [UIImage imageNamed:@"MPCheck"],
             
             // Job Settings
             kMPJobSettingsBackgroundColor:    [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
             kMPJobSettingsPrimaryFont:        [UIFont fontWithName:PGAppAppearanceLightFont size:18],
             kMPJobSettingsPrimaryFontColor:   [UIColor colorWithRed:0x223/255.0F green:0x224/255.0F blue:0x227/255.0F alpha:1.0F],
             kMPJobSettingsSecondaryFont:      [UIFont fontWithName:PGAppAppearanceLightFont size:12],
             kMPJobSettingsSecondaryFontColor: [UIColor colorWithRed:0x223/255.0F green:0x224/255.0F blue:0x227/255.0F alpha:1.0F],
             kMPJobSettingsSelectedPageIcon:   [UIImage imageNamed:@"MPSelected"],
             kMPJobSettingsUnselectedPageIcon: [UIImage imageNamed:@"MPUnselected"],
             kMPJobSettingsSelectedJobIcon:    [UIImage imageNamed:@"MPActiveCircle"],
             kMPJobSettingsUnselectedJobIcon:  [UIImage imageNamed:@"MPInactiveCircle"],
             kMPJobSettingsMagnifyingGlassIcon:[UIImage imageNamed:@"MPMagnify"],
             
             // Main Action
             kMPMainActionBackgroundColor:       [PGAppAppearance navBarColor],
             kMPMainActionLinkFont:              [UIFont fontWithName:PGAppAppearanceLightFont size:18],
             kMPMainActionActiveLinkFontColor:   [UIColor colorWithRed:0x255/255.0F green:0x255/255.0F blue:0x255/255.0F alpha:1.0F],
             kMPMainActionInactiveLinkFontColor: [UIColor colorWithRed:0xAA/255.0F green:0xAA/255.0F blue:0xAA/255.0F alpha:1.0F],
             
             // Queue Project Count
             kMPQueuePrimaryFont:     [UIFont fontWithName:PGAppAppearanceLightFont size:14],
             kMPQueuePrimaryFontColor:[UIColor colorWithRed:0xFF green:0xFF blue:0xFF alpha:1.0F],
             
             // Form Field
             kMPFormFieldBackgroundColor:  [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
             kMPFormFieldPrimaryFont:      [UIFont fontWithName:PGAppAppearanceLightFont size:14],
             kMPFormFieldPrimaryFontColor: [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
             
             // Overlay
             kMPOverlayBackgroundColor:    [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPOverlayBackgroundOpacity:  [NSNumber numberWithFloat:.80F],
             kMPOverlayPrimaryFont:        [UIFont fontWithName:PGAppAppearanceRegularFont size:15],
             kMPOverlayPrimaryFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
             kMPOverlaySecondaryFont:      [UIFont fontWithName:PGAppAppearanceLightFont size:10],
             kMPOverlaySecondaryFontColor: [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
             kMPOverlayLinkFont:           [UIFont fontWithName:PGAppAppearanceRegularFont size:18],
             kMPOverlayLinkFontColor:      [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
             
             // Activity
             kMPActivityPrintIcon:      [UIImage imageNamed:@"printActivityIcon"],
             kMPActivityPrintQueueIcon: [UIImage imageNamed:@"MPPrintLater"],
             };
}

+ (NSDictionary *)hpprAppearanceSettings
{
    NSDictionary *settings = @{
                               kHPPRAppName:                    @"sprocket",
                               kHPPRBackgroundColor:            [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                               kHPPRTintColor:                  [UIColor colorWithRed:0xFF/223.0F green:0xFF/224.0F blue:0xFF/227.0F alpha:1.0F],
                               kHPPRButtonTitleColorSelected:   [UIColor colorWithRed:0xFF/223.0F green:0xFF/224.0F blue:0xFF/227.0F alpha:1.0F],
                               kHPPRButtonTitleColorNormal:     [PGAppAppearance navBarColor],
                               kHPPRPrimaryLabelFont:           [UIFont fontWithName:PGAppAppearanceLightFont size:16.0f],
                               kHPPRPrimaryLabelColor:          [UIColor whiteColor],
                               kHPPRSecondaryLabelFont:         [UIFont fontWithName:PGAppAppearanceLightFont size:12.0f],
                               kHPPRSecondaryLabelColor:        [UIColor colorWithRed:0xFF/223.0F green:0xFF/224.0F blue:0xFF/227.0F alpha:1.0F],
                               kHPPRTableSeparatorColor:        [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                               kHPPRLoadingCellBackgroundColor: [UIColor lightGrayColor]
                               };
    
    return settings;
}

+ (void)addGradientBackgroundToView:(UIView *)view {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0x1f/255.0F green:0x1f/255.0F blue:0x1f/255.0F alpha:1] CGColor], (id)[[UIColor colorWithRed:0x38/255.0F green:0x38/255.0F blue:0x38/255.0F alpha:1] CGColor], nil];
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(1, 0);
    [view.layer insertSublayer:gradient atIndex:0];
}

+ (void)setPrintOptions
{
    [MP sharedInstance].appearance.settings = [PGAppAppearance mpAppearanceSettings];
    [HPPR sharedInstance].appearance.settings = [PGAppAppearance hpprAppearanceSettings];
    
    [MP sharedInstance].useBluetooth = TRUE;
}

+ (UIColor *)navBarColor
{
    return [UIColor colorWithRed:0x2A/255.0F green:0x2A/255.0F blue:0x2A/255.0F alpha:1.0F];
}

@end
