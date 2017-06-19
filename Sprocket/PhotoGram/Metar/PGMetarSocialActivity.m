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
