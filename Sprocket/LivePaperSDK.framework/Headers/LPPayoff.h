//
//  LPPayoff.h
//  LivePaperSDK
//
//  Copyright (c) 2015 Hewlett-Packard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPSession.h"

@interface LPPayoff : NSObject

+ (void) create:(LPSession *) session json:(NSDictionary *) json completionHandler:(void (^)(LPPayoff *payoff, NSError *error)) handler;

+ (void) createWeb:(LPSession *) session name:(NSString *) name url:(NSURL *) url completionHandler:(void (^)(LPPayoff *payoff, NSError *error)) handler;

+ (void) createRich:(LPSession *) session name:(NSString *) name url:(NSURL *) url richPayoffData:(NSDictionary *) richPayoffData completionHandler:(void (^)(LPPayoff *payoff, NSError *error)) handler;

+ (void) get:(LPSession *) session payoffId:(NSString *) payoffId completionHandler:(void (^)(LPPayoff *payoff, NSError *error)) handler;

+ (void) list:(LPSession *) session completionHandler:(void (^)(NSArray *payoffs, NSError *error)) handler;

@property(nonatomic, readonly) NSString *payoffId;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSURL *url;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSDictionary *richPayoffData;
@property(nonatomic, readonly) NSArray *link;

- (BOOL) isWebPayoff;
- (BOOL) isRichPayoff;

- (void) update:(void (^)(NSError *error))handler;

- (void) delete:(void (^)(NSError *error)) handler;

@end
