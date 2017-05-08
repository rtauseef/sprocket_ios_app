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

- (instancetype)initWithToken: (NSString *) accessToken secret:(NSString *) secret accountID:(NSString *) accountID expire: (NSString *) expire
{
    self = [super init];
    if (self) {
        self.accessToken = accessToken;
        self.secret = secret;
        self.accountID = accountID;
        
        double timeInterval = [expire doubleValue];
        NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        self.expire = expireDate;
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
        self.expire = [coder decodeObjectForKey:@"expire"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.accessToken forKey:@"accessToken"];
    [coder encodeObject:self.secret forKey:@"secret"];
    [coder encodeObject:self.accountID forKey:@"accountID"];
    [coder encodeObject:self.expire forKey:@"expire"];
}
@end
