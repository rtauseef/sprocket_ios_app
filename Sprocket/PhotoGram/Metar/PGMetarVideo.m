//
//  PGMetarVideo.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarVideo.h"

@implementation PGMetarVideo

- (instancetype)initWithDictionary: (NSDictionary *) dict
{
    self = [super init];
    if (self) {
        self.length = [[dict objectForKey:@"length"] intValue];
        self.encoding = [dict objectForKey:@"encoding"];
        self.bitrate = [[dict objectForKey:@"bitrate"] intValue];
        self.artist = [dict objectForKey:@"artist"];
    }
    return self;
}

- (NSDictionary *) getDict {
    return @{@"length" : [NSNumber numberWithInt:self.length],
             @"encoding" : self.encoding,
             @"bitrate" : [NSNumber numberWithInt:self.bitrate],
             @"artist" : self.artist};
}

@end
