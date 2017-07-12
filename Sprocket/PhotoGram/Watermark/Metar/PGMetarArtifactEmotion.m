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

#import "PGMetarArtifactEmotion.h"

@implementation PGMetarArtifactEmotion

- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    
    if (self) {
        
        ///TODO: FIX PARSING
        self.smiling = [dict objectForKey:@"smiling"];
        self.eyesOpen = [dict objectForKey:@"eyesOpen"];
        self.eyesOpen = [dict objectForKey:@"mouthOpen"];
    }
    
    return self;
}

- (NSDictionary *) getDict {
    return @{@"smiling": self.smiling,
             @"eyesOpen": self.eyesOpen,
             @"mouthOpen": self.mouthOpen};
}

@end
