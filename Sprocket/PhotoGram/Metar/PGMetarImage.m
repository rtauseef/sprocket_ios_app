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
        self.aperture = [[dict objectForKey:@"aperture"] doubleValue];
        self.exposure = [[dict objectForKey:@"exposure"] doubleValue];
        self.usedFlash = [[dict objectForKey:@"usedFlash"] boolValue];
        self.focalLength = [[dict objectForKey:@"focalLength"] doubleValue];
        self.iso = [dict objectForKey:@"iso"];
        self.make = [dict objectForKey:@"make"];
        self.model = [dict objectForKey:@"model"];
    }
    return self;
}

- (NSDictionary *) getDict {
    return @{@"aperture" : [NSNumber numberWithDouble:self.aperture],
             @"exposure" : [NSNumber numberWithDouble:self.exposure],
             @"usedFlash" : [NSNumber numberWithBool:self.usedFlash],
             @"focalLength" : [NSNumber numberWithDouble:self.focalLength],
             @"iso" : self.iso,
             @"make" : self.make,
             @"model" : self.model};
}

@end
