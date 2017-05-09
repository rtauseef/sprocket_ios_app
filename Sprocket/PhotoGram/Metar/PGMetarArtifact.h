//
//  PGMetarArtifact.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMetarArtifactEmotion.h"

@interface PGMetarArtifact : NSObject

typedef NS_ENUM(NSInteger, PGMetarArtifactType) {
    PGMetarArtifactTypeUnknown,
    PGMetarArtifactTypeFace,
    PGMetarArtifactTypeObject,
    PGMetarArtifactTypeLogo
};

@property (assign, nonatomic) PGMetarArtifactType type;
@property (assign, nonatomic) CGRect *bounds;
@property (assign, nonatomic) int confidence;
@property (strong, nonatomic) PGMetarArtifactEmotion *emotion;
@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) int kind;

- (NSDictionary *) getDict;

@end


