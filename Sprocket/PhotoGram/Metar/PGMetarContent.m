//
//  PGMetarContent.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarContent.h"

@implementation PGMetarContent

- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    
    if (self) {
        if ([dict objectForKey:@"wikipedia"] != nil) {
            self.wikipedia = [[PGMetarContentContainer alloc] initWithDictionary: [dict objectForKey:@"wikipedia"]];
        }
    }
    
    return self;
}

@end
