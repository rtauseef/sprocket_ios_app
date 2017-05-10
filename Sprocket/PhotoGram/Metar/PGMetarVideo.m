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
        self.length = [dict objectForKey:@"length"];
        self.encoding = [dict objectForKey:@"encoding"];
        self.bitrate = [dict objectForKey:@"bitrate"];
        self.artist = [dict objectForKey:@"artist"];
    }
    return self;
}

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.length)
        [dict setObject:self.length forKey:@"length"];
    
    if (self.encoding)
        [dict setObject:self.encoding forKey:@"encoding"];
    
    if (self.bitrate)
        [dict setObject:self.bitrate forKey:@"bitrate"];
    
    if (self.artist)
        [dict setObject:self.artist forKey:@"artist"];

    
    return dict;
}

@end
