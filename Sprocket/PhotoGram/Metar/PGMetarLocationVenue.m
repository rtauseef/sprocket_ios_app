//
//  PGMetarLocationVenue.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarLocationVenue.h"

@implementation PGMetarLocationVenue

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.address)
        [dict setObject:self.address forKey:@"address"];
    
    if (self.city)
        [dict setObject:self.city forKey:@"city"];
    
    if (self.state)
        [dict setObject:self.state forKey:@"state"];
    
    if (self.country)
        [dict setObject:self.country forKey:@"country"];
    
    if (self.countryCode)
        [dict setObject:self.countryCode forKey:@"countryCode"];
    
    if (self.iata)
        [dict setObject:self.iata forKey:@"iata"];
    
    return dict;
}

@end
