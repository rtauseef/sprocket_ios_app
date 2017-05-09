//
//  PGMetarImage.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarImage : NSObject

@property (strong, nonatomic) NSNumber* aperture;
@property (strong, nonatomic) NSNumber* exposure;
@property (strong, nonatomic) NSNumber* usedFlash;
@property (strong, nonatomic) NSNumber* focalLength;
@property (strong, nonatomic) NSString* iso;
@property (strong, nonatomic) NSString* make;
@property (strong, nonatomic) NSString* model;

- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) getDict;

@end
