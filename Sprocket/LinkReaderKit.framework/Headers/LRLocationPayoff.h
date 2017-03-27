//
//  HPLocationPayoff.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRPayoff.h"
@import CoreGraphics;
@import CoreLocation;

/**
 Represents location data
 
 @since 1.0
 */
@interface LRLocationPayoff : NSObject <LRPayoff>

/**
 CLLocation object represnting the given lat/long pair
 
 @since 1.0
 */
@property (nonatomic, readonly) CLLocation *coordinates;

/**
 Creates an instance of LRLocationPayoff using a latitude/longitude pair.

 @param latitude  (double / CLLocationDegrees) latitude in degrees
 @param longitude (double / CLLocationDegrees) longitude in degrees

 @return LRLocationPayoff
 
 @since 1.0
 */
- (instancetype) initWithLatitude:(CGFloat)latitude Longitude:(CGFloat)longitude;

@end
