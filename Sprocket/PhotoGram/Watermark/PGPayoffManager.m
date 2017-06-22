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

#import "PGPayoffManager.h"
#import "PGPayoffMetadata.h"
#import "PGOfflinePayoffDatabase.h"


static NSString * const kOfflineIDUserDefaultsKey = @"pg-payoff-offline-id";
static NSString * const kUniversalURLSchema = @"https";
static NSString * const kUniversalURLHost = @"www.hpsprocket.com"; // TODO make this real
static NSString * const kUniversalURLBasePath = @"meta-payoff";
static NSString * const kUniversalURLLocalPath = @"local";


static NSString * const kPGPayoffManagerDomain = @"com.hp.sprocket.payoffmanager";



@interface PGPayoffManager()

@property NSString * localPayoffFormat;

@end


@implementation PGPayoffManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // create offline ID if it doesn't exist
        _offlineID = [[NSUserDefaults standardUserDefaults] stringForKey:kOfflineIDUserDefaultsKey];
        if( _offlineID == nil ) {
            // create new id
            _offlineID = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setValue:_offlineID forKey:kOfflineIDUserDefaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        self.localPayoffFormat = [NSString stringWithFormat:@"%@://%@/%@/%@/%@/%%@",kUniversalURLSchema,kUniversalURLHost,kUniversalURLBasePath,kUniversalURLLocalPath,self.offlineID];


    }
    return self;
}




+ (instancetype)sharedInstance {
    static PGPayoffManager * shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PGPayoffManager alloc] init];
    });
    return shared;
}


// we're resolving payoffs from URLs because that's what we get from link SDK. Ideally, we could get metadata directly
- (void)resolvePayoffFromURL:(NSURL *)url complete:(void (^)(NSError *error, PGPayoffMetadata *metadata))complete {


    NSArray * components = url.pathComponents;
    if([url.host isEqualToString:kUniversalURLHost] && [components[1] isEqualToString:kUniversalURLBasePath]) {
        // this is possibly a local URL payoff, extract parameters
        // URL has format schema://host/meta-payoff/[local]/ownId/payoffId
        //                  components:    1          2      3     4
        if( [components[2] isEqualToString:kUniversalURLLocalPath] && components.count >= 5 ) {
            // local path
            if([components[3] isEqualToString:self.offlineID] ) {
                // I myself created this content

                // now load metadata from offline database

                PGPayoffMetadata *  meta = [[PGOfflinePayoffDatabase sharedInstance] loadMetadata:components[4]];
                if( meta ) {
                    complete(nil,meta);
                } else {
                    complete([NSError errorWithDomain:kPGPayoffManagerDomain code:kPGPayoffErrorNoLocalEntry userInfo:nil],nil);
                }

            } else {
                // offline content can only be retrieved by the creator
                complete([NSError errorWithDomain:kPGPayoffManagerDomain code:kPGPayoffErrorLocalIdentityMismatch userInfo:nil],nil);
            }


        } else {
            // don't know what to do if it's not local
            complete([NSError errorWithDomain:kPGPayoffManagerDomain code:kPGPayoffErrorNotImplemented userInfo:nil],nil);
        }
    
    } else {
        // resolve as a URL metadata
        complete(nil,[PGPayoffMetadata onlineURLPayoff:url]);
    }
}


- (NSURL *)createURLWithPayoff:(PGPayoffMetadata *)meta {
    if( meta.offline ) {
        // offline database engaged. create UniversalLink url
        return [NSURL URLWithString:[NSString stringWithFormat:self.localPayoffFormat,meta.uuid]];
    } else {
        return [meta URL];
    }
}


@end
