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

#import "PGImageCache.h"

@interface PGImageCache ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation PGImageCache

+ (instancetype)sharedInstance
{
    static PGImageCache *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PGImageCache alloc] init];
    });

    return instance;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.cache = [[NSCache alloc] init];
    }

    return self;
}

- (void)setImage:(UIImage *)image ForKey:(NSString *)key
{
    [self.cache setObject:image forKey:key];
}

- (UIImage *)imageForKey:(NSString *)key
{
    return [self.cache objectForKey:key];
}

@end
