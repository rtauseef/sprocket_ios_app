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
#import "PGMetarArtifactEmotion.h"

@interface PGMetarArtifact : NSObject

typedef NS_ENUM(NSInteger, PGMetarArtifactType) {
    PGMetarArtifactTypeUnknown,
    PGMetarArtifactTypeFace,
    PGMetarArtifactTypeObject,
    PGMetarArtifactTypeLogo,
    PGMetarArtifactTypeOrbFeature
};

@property (assign, nonatomic) PGMetarArtifactType type;
@property (assign, nonatomic) CGRect bounds;
@property (assign, nonatomic) int confidence;
@property (strong, nonatomic) PGMetarArtifactEmotion *emotion;
@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) int kind;
@property (strong, nonatomic) NSData *keypoints;
@property (strong, nonatomic) NSData *descriptors;

- (NSDictionary *) getDict;
- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end


