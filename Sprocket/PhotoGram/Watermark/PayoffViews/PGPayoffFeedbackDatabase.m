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

#import "PGPayoffFeedbackDatabase.h"

static NSString * const kPayoffFeedbackDatabase = @"pg-payoff-feedback-db";

@implementation PGPayoffFeedbackDatabase

+(instancetype) sharedInstance {
    static PGPayoffFeedbackDatabase * shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PGPayoffFeedbackDatabase alloc] init];
    });
    return shared;
}

- (NSString *) guidForMedia:(PGMetarMedia *)media andKind: (PGPayoffFeedbackDatabaseViewKind)kind {
    NSMutableString *guid = [NSMutableString string];
    
    if (media.source.identifier != nil) {
        [guid appendString:media.source.identifier];
    }
    
    if (media.source.uri != nil) {
        [guid appendString:media.source.uri];
    }
    
    if (![guid isEqualToString:@""]) {
        [guid appendString:[NSString stringWithFormat:@"_%ld",kind]];
    }
    
    return guid;
}

- (PGPayoffFeedbackDatabaseResult) checkFeedbackForMedia:(PGMetarMedia *)media andViewKind:(PGPayoffFeedbackDatabaseViewKind)kind {

    NSString *guid = [self guidForMedia:media andKind:kind];
    
    NSDictionary * data = [[NSUserDefaults standardUserDefaults] objectForKey:kPayoffFeedbackDatabase];
    if( data && ![guid isEqualToString:@""] ) {
        NSNumber *rate = [data objectForKey:guid];
        if (rate != nil) {
            int thumbs = [rate intValue];
            
            switch (thumbs) {
                case PGPayoffFeedbackDatabaseResultThumbsUp:
                    return PGPayoffFeedbackDatabaseResultThumbsUp;
                    break;
                case PGPayoffFeedbackDatabaseResultThumbsDown:
                    return PGPayoffFeedbackDatabaseResultThumbsDown;
                default:
                    break;
            }
        }
    }
    
    return PGPayoffFeedbackDatabaseResultEmpty;
}

- (void) saveFeedbackForMedia:(PGMetarMedia *)media withViewKind:(PGPayoffFeedbackDatabaseViewKind)kind andFeedback:(PGPayoffFeedbackDatabaseResult)feedback {
    
    NSMutableDictionary * data = [[[NSUserDefaults standardUserDefaults] objectForKey:kPayoffFeedbackDatabase] mutableCopy];
    
    if( ! data ) {
        data = [NSMutableDictionary dictionary];
    }
    
    [data setObject:[NSNumber numberWithInteger:feedback] forKey:[self guidForMedia:media andKind:kind]];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kPayoffFeedbackDatabase];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
