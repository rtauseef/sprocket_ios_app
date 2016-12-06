//
//  LPLink.h
//  LivePaperSDK
//
//  Copyright (c) 2015 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPSession.h"

@interface LPLink : NSObject

+ (void) create:(LPSession *) session name:(NSString *) name triggerId:(NSString *) triggerId payoffId:(NSString *) payoffId completionHandler:(void (^)(LPLink *link, NSError *error)) handler;

+ (void) get:(LPSession *) session linkId:(NSString *) linkId completionHandler:(void (^)(LPLink *link, NSError *error)) handler;

+ (void) list:(LPSession *) session completionHandler:(void (^)(NSArray *links, NSError *error)) handler;

@property(nonatomic, readonly) NSString *linkId;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, readonly) NSString *triggerId;
@property(nonatomic, readonly) NSString *payoffId;
@property(nonatomic, readonly) NSArray *link;

- (void) update:(void (^)(NSError *error))handler;

- (void) delete:(void (^)(NSError *error)) handler;

@end
