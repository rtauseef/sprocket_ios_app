//
// HP Inc.
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
#import "MPBTSprocketDefinitions.h"

@protocol MPBTAutoOffTableViewControllerDelegate;

@interface MPBTAutoOffTableViewController : UITableViewController

@property (assign, nonatomic) SprocketAutoPowerOffInterval currentAutoOffValue;
@property (weak, nonatomic) id<MPBTAutoOffTableViewControllerDelegate> delegate;

@end

@protocol MPBTAutoOffTableViewControllerDelegate <NSObject>

- (void)didSelectAutoOffInterval:(SprocketAutoPowerOffInterval)sprocket;

@end;
