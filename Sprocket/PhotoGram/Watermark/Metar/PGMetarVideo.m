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
    
    if (self.length && !isnan([self.length doubleValue]))
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
