//
//  PGMetarImage.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarImage.h"

@implementation PGMetarImage

- (instancetype)initWithDictionary: (NSDictionary *) dict
{
    self = [super init];
    if (self) {
        self.aperture = [dict objectForKey:@"aperture"];
        self.exposure = [dict objectForKey:@"exposure"];
        self.usedFlash = [dict objectForKey:@"usedFlash"];
        self.focalLength = [dict objectForKey:@"focalLength"];
        self.iso = [dict objectForKey:@"iso"];
        self.make = [dict objectForKey:@"make"];
        self.model = [dict objectForKey:@"model"];
    }
    return self;
}

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.aperture)
        [dict setObject:self.aperture forKey:@"aperture"];
    
    if (self.exposure)
        [dict setObject:self.exposure forKey:@"exposure"];
    
    if (self.usedFlash)
        [dict setObject:self.usedFlash forKey:@"usedFlash"];
    
    if (self.focalLength)
        [dict setObject:self.focalLength forKey:@"focalLength"];
    
    if (self.iso)
        [dict setObject:self.iso forKey:@"iso"];
    
    if (self.make)
        [dict setObject:self.make forKey:@"make"];
    
    if (self.model)
        [dict setObject:self.model forKey:@"model"];
    
    return dict;
}

@end
