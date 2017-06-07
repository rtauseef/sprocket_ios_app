//
//  PGAurasmaGlobalContext.h
//  Sprocket
//
//  Created by Alex Walter on 06/06/2017.
//  Copyright © 2017 HP. All rights reserved.
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
