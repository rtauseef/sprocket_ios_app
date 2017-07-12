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

#import "PGMetarLocation.h"

@implementation PGMetarLocation

- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [self init];
    
    if (self) {
        NSDictionary *geo = [dict objectForKey:@"geo"];
        if (geo != nil && ![geo isKindOfClass:[NSNull class]]) {
            NSNumber *lat = [geo objectForKey:@"lat"];
            NSNumber *lon = [geo objectForKey:@"lon"];
            
            if (lat && lon) {
                self.geo = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
            }
        }
        
        self.name = [dict objectForKey:@"name"];
        self.altitude = [dict objectForKey:@"altitude"];
        
        if ([dict objectForKey:@"type"] != nil ) {
            self.type = [self getTypeFromString:[dict objectForKey:@"type"]];
        }
        
        if ([dict objectForKey:@"kind"] != nil) {
            self.kind = [self getKindFromString:[dict objectForKey:@"kind"]];
        }
        
        if ([dict objectForKey:@"venue"] != nil) {
            self.venue = [[PGMetarLocationVenue alloc] initWithDictionary: [dict objectForKey:@"venue"]];
        }
        
        if ([dict objectForKey:@"content"] != nil && ![[dict objectForKey:@"content"] isEqual:[NSNull null]]) {
            self.content = [[PGMetarContent alloc] initWithDictionary: [dict objectForKey:@"content"]];
        }
    }
    
    return self;
}

- (PGMetarLocationKind) getKindFromString: (NSString *) kind {
    if ([kind isEqual:[NSNull null]]) {
        return PGMetarLocationKindUnknown;
    }
    
    if ([kind rangeOfString:@"indoor" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarLocationKindIndoor;
    } else if ([kind rangeOfString:@"outdoor" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarLocationKindOutdoor;
    } else {
        return PGMetarLocationKindUnknown;
    }
}

- (PGMetarLocationType) getTypeFromString: (NSString *) type {
    if ([type isEqual:[NSNull null]]) {
        return PGMetarLocationTypeUnknown;
    }

    if ([type rangeOfString:@"address" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarLocationTypeAddress;
    } else if ([type rangeOfString:@"monument" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarLocationTypeMonument;
    }
    
    return PGMetarLocationTypeUnknown;
}

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
