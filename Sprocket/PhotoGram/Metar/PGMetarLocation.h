//
//  PGMetarLocation.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "PGMetarLocationVenue.h"

@interface PGMetarLocation : NSObject

typedef NS_ENUM(NSInteger, PGMetarLocationType) {
    PGMetarLocationTypeUnknown,
    PGMetarLocationTypeAddress,
    PGMetarLocationTypeMonument
};

typedef NS_ENUM(NSInteger, PGMetarLocationKind) {
    PGMetarLocationKindUnknown,
    PGMetarLocationKindIndoor,
    PGMetarLocationKindOutdoor
};

@property (assign, nonatomic) CLLocationCoordinate2D geo;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) double altitude;
@property (assign, nonatomic) PGMetarLocationType type;
@property (assign, nonatomic) PGMetarLocationKind kind;
@property (strong, nonatomic) PGMetarLocationVenue *venue;

- (NSDictionary *) getDict;

@end
