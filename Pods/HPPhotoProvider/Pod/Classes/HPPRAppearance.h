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

@interface HPPRAppearance : NSObject

extern NSString * const kHPPRBackgroundColor;
extern NSString * const kHPPRTableSeparatorColor;
extern NSString * const kHPPRTintColor;
extern NSString * const kHPPRPrimaryLabelFont;
extern NSString * const kHPPRPrimaryLabelColor;
extern NSString * const kHPPRSecondaryLabelFont;
extern NSString * const kHPPRSecondaryLabelColor;
extern NSString * const kHPPRButtonTitleColorSelected;
extern NSString * const kHPPRButtonTitleColorNormal;
extern NSString * const kHPPRLoadingCellBackgroundColor;

@property (strong, nonatomic) NSDictionary *settings;

@end
