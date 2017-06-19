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

@interface PGMetarLocationVenue : NSObject

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *iata;
@property (strong, nonatomic) NSString *area;

- (NSDictionary *) getDict;
- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end
