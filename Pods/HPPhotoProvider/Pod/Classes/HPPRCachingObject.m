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

@property (strong, nonatomic) NSMutableDictionary *cacheStorage;

@end

@implementation HPPRCachingObject

- (id)init
{
    if ((self = [super init])) {
        self.cacheStorage = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLowMemory:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleLowMemory:(NSNotification *)notification
{
    [self clearCache];
}

- (void)clearCache
{
    @synchronized(self) {
        [self.cacheStorage removeAllObjects];
    }
}

- (void)saveToCache:(id)object withKey:(id)key
{
    @synchronized(self) {
        if(object)
        {
            [self.cacheStorage setObject:object forKey:key];
        }
    }
}

- (id)retrieveFromCacheWithKey:(id)key
{
    @synchronized(self) {
        return [self.cacheStorage objectForKey:key];
    }
}

@end
