//
//  PGMetarImageTag.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/4/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarImageTag.h"

@implementation PGMetarImageTag

- (instancetype)initWithDate: (NSDate *) at andResource: (NSString *) resource andMedia: (NSString *) media
{
    self = [super init];
    
    if (self) {
        self.at = at;
        self.resource = resource;
        self.media = media;
    }
    
    return self;
}

@end
