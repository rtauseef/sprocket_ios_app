//
//  PGMetarImageTag.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/4/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarImageTag : NSObject

@property (strong, nonatomic) NSDate *at;
@property (strong, nonatomic) NSString *resource;
@property (strong, nonatomic) NSString *media;

- (instancetype)initWithDate: (NSDate *) at andResource: (NSString *) resource andMedia: (NSString *) media;

- (NSDictionary *) getDict;

@end
