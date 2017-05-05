//
//  PGMetarMedia.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/4/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarMedia.h"

@implementation PGMetarMedia

- (instancetype)initWithDictionary: (NSDictionary *) dict
{
    self = [super init];
    if (self) {
        self.mime = [dict objectForKey:@"mime"];
    }
    return self;
}

- (NSDictionary *) getDict {
    return @{@"mime" : self.mime};
}

@end
