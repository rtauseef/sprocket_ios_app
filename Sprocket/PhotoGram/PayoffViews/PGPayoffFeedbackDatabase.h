//
//  PGPayoffFeedbackDatabase.h
//  Sprocket
//
//  Created by Fernando Caprio on 6/16/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMetarMedia.h"

@interface PGPayoffFeedbackDatabase : NSObject

typedef NS_ENUM(NSInteger, PGPayoffFeedbackDatabaseViewKind) {
    PGPayoffFeedbackDatabaseViewKindVideo = 100,
    PGPayoffFeedbackDatabaseViewKindLivePhoto = 200,
    PGPayoffFeedbackDatabaseViewKindImageByDate= 300,
    PGPayoffFeedbackDatabaseViewKindImageByLocation = 310,
    PGPayoffFeedbackDatabaseViewKindWikipedia = 400,
    PGPayoffFeedbackDatabaseViewKindUnknown = 0
};

typedef NS_ENUM(NSInteger, PGPayoffFeedbackDatabaseResult) {
    PGPayoffFeedbackDatabaseResultThumbsUp = 1,
    PGPayoffFeedbackDatabaseResultThumbsDown = 2,
    PGPayoffFeedbackDatabaseResultEmpty = 3
};


+(instancetype) sharedInstance;

- (PGPayoffFeedbackDatabaseResult) checkFeedbackForMedia: (PGMetarMedia *) media andViewKind: (PGPayoffFeedbackDatabaseViewKind) kind;

- (void) saveFeedbackForMedia: (PGMetarMedia *) media withViewKind: (PGPayoffFeedbackDatabaseViewKind) kind andFeedback: (PGPayoffFeedbackDatabaseResult) feedback;

@end
