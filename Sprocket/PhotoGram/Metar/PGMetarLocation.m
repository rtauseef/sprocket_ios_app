//
//  PGMetarLocation.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarLocation.h"

@implementation PGMetarLocation

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    //TODO: 0,0 is valid
    if (self.geo.latitude != 0 || self.geo.longitude != 0) {
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
    
    return dict;
}

@end
