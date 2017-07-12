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
