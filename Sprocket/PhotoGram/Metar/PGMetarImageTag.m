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

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.at)
        [dict setObject:[NSNumber numberWithDouble:[self.at timeIntervalSince1970]] forKey:@"at"];
    
    if (self.resource)
        [dict setObject:self.resource forKey:@"resource"];
    
    if (self.media)
        [dict setObject:self.media forKey:@"media"];
    
    return dict;
}

@end
