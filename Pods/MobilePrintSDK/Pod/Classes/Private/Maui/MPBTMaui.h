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

#import <Foundation/Foundation.h>
#import "MPBTMauiDefinitions.h"
#import "MPBTSprocket+Protected.h"

@protocol MPBTSprocketDelegate;

@interface MPBTMaui : MPBTSprocket

+ (MPBTMaui *)sharedInstance;

@property (assign, nonatomic, readonly) NSUInteger cnxVersion;
@property (assign, nonatomic, readonly) NSUInteger tmdVersion;
@property (strong, nonatomic, readonly) NSString *serialNumber;

@end
