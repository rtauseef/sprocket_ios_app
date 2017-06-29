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

extern NSString * _Nonnull kPGSettingsForceFirmwareUpgrade;

@interface PGLoggingSetttingsViewController : UITableViewController

@property (strong, nonatomic) NSString * _Nullable unlockCode;

- (BOOL)validCode:(NSString *_Nullable)code;

@end
