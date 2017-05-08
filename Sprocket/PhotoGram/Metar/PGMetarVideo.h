//
//  PGMetarVideo.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarVideo : NSObject

@property (assign, nonatomic) int length;
@property (strong, nonatomic) NSString* encoding;
@property (assign, nonatomic) int bitrate;
@property (strong, nonatomic) NSString* artist;

- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) getDict;

@end
