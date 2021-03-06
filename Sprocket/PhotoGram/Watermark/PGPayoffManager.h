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
#import "PGPayoffMetadata.h"

enum {
    kPGPayoffErrorUndefined,
    kPGPayoffErrorNotImplemented,
    kPGPayoffErrorNoLocalEntry,
    kPGPayoffErrorLocalIdentityMismatch
};

@interface PGPayoffManager : NSObject

@property (readonly) NSString* offlineID;

+(instancetype) sharedInstance;


-(void)resolvePayoffFromURL:(NSURL *)url complete:(void (^)(NSError * error, PGPayoffMetadata * metadata)) complete;


-(NSURL *) createURLWithPayoff:(PGPayoffMetadata *) meta;

@end
