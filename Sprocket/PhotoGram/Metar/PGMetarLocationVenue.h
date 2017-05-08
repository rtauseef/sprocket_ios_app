//
//  PGMetarLocationVenue.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarLocationVenue : NSObject

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *iata;

@end
