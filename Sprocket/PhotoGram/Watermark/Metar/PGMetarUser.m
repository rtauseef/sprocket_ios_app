//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "PGMetarUser.h"

@implementation PGMetarUser

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
