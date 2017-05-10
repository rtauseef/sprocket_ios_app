//
//  PGMetarLocation.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarLocation.h"

@implementation PGMetarLocation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.geo = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (CLLocationCoordinate2DIsValid(self.geo)) {
        NSDictionary *geo = @{@"lat": [NSNumber numberWithDouble:self.geo.latitude],
                              @"lon": [NSNumber numberWithDouble:self.geo.longitude]};
        [dict setObject:geo forKey:@"geo"];
    }
    
    if (self.altitude) {
        [dict setObject:self.altitude forKey:@"elevation"];
    }
    
    if (self.name) {
        [dict setObject:self.name forKey:@"name"];
    }
    
    if (self.venue) {
        [dict setObject:[self.venue getDict] forKey:@"venue"];
    }
    
    return dict;
}

@end
