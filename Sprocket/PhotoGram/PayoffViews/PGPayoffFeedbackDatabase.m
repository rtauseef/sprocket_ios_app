//
//  PGPayoffFeedbackDatabase.m
//  Sprocket
//
//  Created by Fernando Caprio on 6/16/17.
//  Copyright © 2017 HP. All rights reserved.
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

- (NSString *) guidForMedia: (PGMetarMedia *) media andKind: (PGPayoffFeedbackDatabaseViewKind) kind {
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

- (PGPayoffFeedbackDatabaseResult) checkFeedbackForMedia: (PGMetarMedia *) media andViewKind: (PGPayoffFeedbackDatabaseViewKind) kind {

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

- (void) saveFeedbackForMedia: (PGMetarMedia *) media withViewKind: (PGPayoffFeedbackDatabaseViewKind) kind andFeedback: (PGPayoffFeedbackDatabaseResult) feedback {
    
    NSMutableDictionary * data = [[[NSUserDefaults standardUserDefaults] objectForKey:kPayoffFeedbackDatabase] mutableCopy];
    
    if( ! data ) {
        data = [NSMutableDictionary dictionary];
    }
    
    [data setObject:[NSNumber numberWithInteger:feedback] forKey:[self guidForMedia:media andKind:kind]];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kPayoffFeedbackDatabase];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
