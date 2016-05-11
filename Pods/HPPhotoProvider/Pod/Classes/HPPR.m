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

#import "HPPR.h"

NSString * const kHPPRTrackableScreenNameKey = @"screen-name";

@implementation HPPR

+ (HPPR *)sharedInstance
{
    static dispatch_once_t once;
    static HPPR *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPR alloc] init];
    });
    return sharedInstance;
}

@end
