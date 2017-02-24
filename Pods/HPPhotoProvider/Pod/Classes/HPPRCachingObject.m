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

#import "HPPRCachingObject.h"

@interface HPPRCachingObject()

@property (strong, nonatomic) NSCache *cacheStorage;

@end

@implementation HPPRCachingObject

- (id)init
{
    self = [super init];

    if (self) {
        self.cacheStorage = [[NSCache alloc] init];
    }
    
    return self;
}

- (void)clearCache
{
    [self.cacheStorage removeAllObjects];
}

- (void)saveToCache:(id)object withKey:(id)key
{
    if (object) {
        [self.cacheStorage setObject:object forKey:key];
    }
}

- (id)retrieveFromCacheWithKey:(id)key
{
    return [self.cacheStorage objectForKey:key];
}

@end
