//
//  PGMetarArtifactEmotion.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarArtifactEmotion : NSObject

@property (strong, nonatomic) NSNumber *smiling;
@property (strong, nonatomic) NSNumber *eyesOpen;
@property (strong, nonatomic) NSNumber *mouthOpen;

- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) getDict;

@end
