//
//  PGMetarUser.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/3/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarUser.h"

@implementation PGMetarUser

- (instancetype)init
{
    self = [super init];
    if (self) {
    
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.accessToken = [coder decodeObjectForKey:@"accessToken"];
        self.secret = [coder decodeObjectForKey:@"secret"];
        self.accountID = [coder decodeObjectForKey:@"accountID"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.accessToken forKey:@"accessToken"];
    [coder encodeObject:self.secret forKey:@"secret"];
    [coder encodeObject:self.accountID forKey:@"accountID"];
}
@end
