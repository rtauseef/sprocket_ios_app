//
//  PGImageItem.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarImageItem.h"

@implementation PGMetarImageItem

- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    
    if (self) {
        self.index = [dict objectForKey:@"index"];
        self.thumbnail = [dict objectForKey:@"thumbnail"];
        self.original = [dict objectForKey:@"original"];
        self.reference = [dict objectForKey:@"reference"];
        self.label = [dict objectForKey:@"label"];
        self.imageDescription = [dict objectForKey:@"description"];
    }
    
    return self;
}

@end
