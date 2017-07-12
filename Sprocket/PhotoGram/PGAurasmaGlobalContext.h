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
#import <AurasmaSDK/AURContext.h>

@interface PGAurasmaGlobalContext : NSObject

+ (PGAurasmaGlobalContext *)instance;

@property (readonly) AURContext *context;
@property (readonly) NSString *guestName;
@property (readonly) BOOL syncing;

- (void)loginAndStartSync;

- (void)stopSync;

- (void)startSync;

@end
