//
//  PGMetarSocialActivity.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/9/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarSocialActivity.h"

@implementation PGMetarSocialActivity

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
