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

#import "PGMetarLocationVenue.h"

@implementation PGMetarLocationVenue

- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    
    if (self) {
        
        if (![dict isEqual:[NSNull null]]) {
            self.address = [dict objectForKey:@"address"];
            self.city = [dict objectForKey:@"city"];
            self.state = [dict objectForKey:@"state"];
            self.countryCode = [dict objectForKey:@"countryCode"];
            self.country = [dict objectForKey:@"country"];
            self.iata = [dict objectForKey:@"iata"];
            self.area = [dict objectForKey:@"area"];
        }
    }

    return self;
}

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
    
    if (self.area)
        [dict setObject:self.area forKey:@"area"];
    
    return dict;
}

@end
