//
//  PGMetarSource.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/4/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PGMetarSourceFrom) {
    PGMetarSourceFromLocal,
    PGMetarSourceFromSocial,
    PGMetarSourceFromShared,
    PGMetarSourceFromMetar,
    PGMetarSourceFromOther
};

typedef NS_ENUM(NSInteger, PGMetarSourceOrigin) {
    PGMetarSourceOriginStorage,
    PGMetarSourceOriginOpenIn,
    PGMetarSourceOriginDownloaded
};

@interface PGMetarSource : NSObject

@property (assign, nonatomic) PGMetarSourceFrom from;
@property (assign, nonatomic) PGMetarSourceOrigin origin;
@property (strong, nonatomic) NSString* uri;
@property (strong, nonatomic) NSString* album;
@property (strong, nonatomic) NSString* social;
@property (strong, nonatomic) NSString* identifier;
@property (strong, nonatomic) NSString* owner;

- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) getDict;

@end
