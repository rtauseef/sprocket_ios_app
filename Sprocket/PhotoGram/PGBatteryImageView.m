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

#import "PGBatteryImageView.h"

@implementation PGBatteryImageView

- (void)setLevel:(NSUInteger)level
{
    if (level > 75 && level <= 100) {
        self.image = [UIImage imageNamed:@"battery100"];
    } else if (level < 75 && level >= 50) {
        self.image = [UIImage imageNamed:@"battery75"];
    } else if (level < 50 && level >= 25) {
        self.image = [UIImage imageNamed:@"battery50"];
    } else if (level < 25) {
        self.image = [UIImage imageNamed:@"battery25"];
    }
}

@end
