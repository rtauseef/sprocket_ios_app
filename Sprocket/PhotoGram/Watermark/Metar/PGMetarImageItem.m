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
