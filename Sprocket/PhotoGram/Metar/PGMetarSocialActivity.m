//
//  PGMetarSocialActivity.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/9/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarSocialActivity.h"

@implementation PGMetarSocialActivity

- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    if (self) {
        self.likes = [dict objectForKey:@"likes"];
        self.shares = [dict objectForKey:@"shares"];
        self.comments = [dict objectForKey:@"comments"];
    }
    return self;
}

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.likes)
        [dict setObject:self.likes forKey:@"likes"];
    
    if (self.comments)
        [dict setObject:self.comments forKey:@"comments"];
  
    if (self.shares)
        [dict setObject:self.shares forKey:@"shares"];
    
    return dict;
}

@end
