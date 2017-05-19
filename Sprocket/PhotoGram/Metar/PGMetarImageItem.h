//
//  PGImageItem.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarImageItem : NSObject

@property (strong, nonatomic) NSNumber* index;
@property (strong, nonatomic) NSString* thumbnail;
@property (strong, nonatomic) NSString* original;
@property (strong, nonatomic) NSString* reference;
@property (strong, nonatomic) NSString* label;
@property (strong, nonatomic) NSString* imageDescription;

- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end
