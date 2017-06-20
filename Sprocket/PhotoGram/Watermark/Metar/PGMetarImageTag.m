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
