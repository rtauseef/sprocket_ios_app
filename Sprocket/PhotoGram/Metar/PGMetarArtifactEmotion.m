//
//  PGMetarArtifactEmotion.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
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
