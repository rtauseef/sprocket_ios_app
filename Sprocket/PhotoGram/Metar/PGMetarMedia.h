//
//  PGMetarMedia.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/4/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMetarSource.h"
#import "PGMetarVideo.h"
#import "PGMetarImage.h"
#import "PGMetarArtifact.h"
#import "PGMetarLocation.h"

typedef NS_ENUM(NSInteger, PGMetarMediaType) {
    PGMetarMediaTypeImage,
    PGMetarMediaTypeVideo
};

typedef NS_ENUM(NSInteger, PGMetarMediaOrientation) {
    PGMetarMediaOrientationPortrait,
    PGMetarMediaOrientationLandscape
};

@interface PGMetarMedia : NSObject

@property (assign, nonatomic) PGMetarMediaType mediaType;
@property (strong, nonatomic) NSString *mime;
@property (assign, nonatomic) double *size;
@property (assign, nonatomic) PGMetarMediaOrientation orientation;
@property (assign, nonatomic) CGSize pixels;
@property (assign, nonatomic) CGSize inches;
@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSDate *submited;
@property (strong, nonatomic) NSDate *lastQueried;
@property (strong, nonatomic) PGMetarSource *source;
@property (strong, nonatomic) NSArray<NSString *> *tags;
@property (strong, nonatomic) PGMetarVideo *video;
@property (strong, nonatomic) PGMetarImage *image;
@property (strong, nonatomic) NSArray<PGMetarArtifact *> *artifacts;
@property (strong, nonatomic) PGMetarLocation *location;

- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) getDict;

@end
