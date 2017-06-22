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

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "PGMetarLocationVenue.h"
#import "PGMetarContent.h"

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
@property (strong, nonatomic) NSNumber *altitude;
@property (assign, nonatomic) PGMetarLocationType type;
@property (assign, nonatomic) PGMetarLocationKind kind;
@property (strong, nonatomic) PGMetarLocationVenue *venue;
@property (strong, nonatomic) PGMetarContent *content;

- (NSDictionary *) getDict;
- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end
