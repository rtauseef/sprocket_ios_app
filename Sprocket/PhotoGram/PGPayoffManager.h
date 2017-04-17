//
//  PGPayoffManager.h
//  Sprocket
//
//  Created by Bruno Dal Bo on 4/17/17.
//  Copyright © 2017 HP. All rights reserved.
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
