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
#import "PGMetarSource.h"
#import "PGMetarVideo.h"
#import "PGMetarImage.h"
#import "PGMetarArtifact.h"
#import "PGMetarLocation.h"
#import "HPPRMedia.h"
#import "PGEmbellishmentMetricsManager.h"

typedef NS_ENUM(NSInteger, PGMetarMediaType) {
    PGMetarMediaTypeUnknown,
    PGMetarMediaTypeImage,
    PGMetarMediaTypeVideo
};

typedef NS_ENUM(NSInteger, PGMetarMediaOrientation) {
    PGMetarMediaOrientationUnknown,
    PGMetarMediaOrientationPortrait,
    PGMetarMediaOrientationLandscape
};

@interface PGMetarMedia : NSObject

@property (assign, nonatomic) PGMetarMediaType mediaType;
@property (strong, nonatomic) NSString *mime;
@property (strong, nonatomic) NSNumber *size;
@property (assign, nonatomic) PGMetarMediaOrientation orientation;
@property (assign, nonatomic) CGSize pixels;
@property (assign, nonatomic) CGSize inches;
@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSDate *submitted;
@property (strong, nonatomic) NSDate *lastQueried;
@property (strong, nonatomic) PGMetarSource *source;
@property (strong, nonatomic) NSArray<NSString *> *tags;
@property (strong, nonatomic) PGMetarVideo *video;
@property (strong, nonatomic) PGMetarImage *image;
@property (strong, nonatomic) NSArray<PGMetarArtifact *> *artifacts;
@property (strong, nonatomic) PGMetarLocation *location;

- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) getDict;
+ (instancetype)metaFromHPPRMedia: (HPPRMedia *) media;
+ (instancetype)metaFromHPPRMedia: (HPPRMedia *) media andEmbellishmentManager:(PGEmbellishmentMetricsManager *)embellishmentManager;

@end
