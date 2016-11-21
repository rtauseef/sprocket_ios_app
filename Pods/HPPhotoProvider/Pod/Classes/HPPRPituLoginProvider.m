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

#import "HPPRPituLoginProvider.h"

@implementation HPPRPituLoginProvider

#pragma mark - Initialization

+ (HPPRPituLoginProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRPituLoginProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRPituLoginProvider alloc] init];
    });
    return sharedInstance;
}

@end
