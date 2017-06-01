//
//  PGMetarOfflineTagManager.m
//  Sprocket
//
//  Created by Fernando Caprio on 6/1/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarOfflineTagManager.h"
#import "PGMetarAPI.h"

#define kOfflineTagSaveName @"OFFLINE_TAG_METAR_DB"

@interface PGMetarOfflineTagManager()

@property (atomic, strong) NSMutableDictionary * _Nullable availableTags;

@end

@implementation PGMetarOfflineTagManager

+ (PGMetarOfflineTagManager *)sharedInstance
{
    static dispatch_once_t once;
    static PGMetarOfflineTagManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGMetarOfflineTagManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.availableTags = [NSMutableDictionary dictionaryWithDictionary:self.fetchLocalDatabase];
    }
    return self;
}

- (NSDictionary *) fetchLocalDatabase {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *offlineTagDict = [defaults dictionaryForKey:kOfflineTagSaveName];
    
    if (offlineTagDict == nil) {
        offlineTagDict = [NSDictionary dictionary];
    }
    
    return offlineTagDict;
}

- (int) tagCount {
    int count = 0;
    
    for (NSObject *obj in [self.availableTags allValues]) {
        if ([obj isKindOfClass:[NSData class]]) {
            count++;
        }
    }
    
    return count;
}

- (void) saveLocalDatabase: (NSDictionary *) dict {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    NSMutableDictionary *saveDict = [NSMutableDictionary dictionary];
    for (NSString *key in [dict allKeys]) {
        if ([[dict valueForKey:key] isKindOfClass:[NSData class]]) {
            [saveDict setObject:[dict valueForKey:key] forKey:key];
        }
    }
    
    [defaults setObject:saveDict forKey:kOfflineTagSaveName];
    [defaults synchronize];
}

- (UIImage *) downloadImageForTag: (NSString *) tag {
    PGMetarAPI *api = [[PGMetarAPI alloc] init];
    
    PGMetarImageTag *imageTag = [[PGMetarImageTag alloc] init];
    imageTag.media = [NSString stringWithFormat:@"/resource/tag/%@/media",tag];
    imageTag.resource = tag;
    
    __block dispatch_group_t taggingGroup = dispatch_group_create();
    
    __block UIImage *returnImage;
    
    dispatch_group_enter(taggingGroup);
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [api downloadWatermarkedImage:imageTag completion:^(NSError * _Nullable error, UIImage * _Nullable watermarkedImage) {
            returnImage = watermarkedImage;
            dispatch_group_leave(taggingGroup);
        }];
    });
    
    dispatch_group_wait(taggingGroup, DISPATCH_TIME_FOREVER);
    
    return returnImage;
}

- (void) checkTagDB: (nullable void (^)()) completion {
    PGMetarAPI *api = [[PGMetarAPI alloc] init];
    
    [api authenticate:^(BOOL success) {
        if (success) {
            // fetch tags
            [api getOfflineTags:^(NSError * _Nullable error, NSArray * _Nullable tags) {
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    @synchronized(self) {
                        NSDictionary *offlineDict = self.availableTags;
                        
                        NSMutableDictionary *updatedDict = [NSMutableDictionary dictionaryWithDictionary:offlineDict];
                        
                        BOOL needsUpdate = NO;
                        
                        for (NSString *tag in tags) {
                            if ([updatedDict objectForKey:tag] == nil) {
                                
                                UIImage *watermarkedImage = [self downloadImageForTag:tag];
                                if (watermarkedImage != nil) {
                                    NSData* imageData = UIImagePNGRepresentation(watermarkedImage);
                                    [updatedDict setObject:imageData forKey:tag];
                                    needsUpdate = YES;
                                }
                            }
                        }
                        
                        if (needsUpdate) {
                            [self updateDictWithDict:updatedDict];
                            [self saveLocalDatabase:self.availableTags];
                            
                            NSLog(@"Tag count updated: %lu",[self.availableTags count]);
                        }
                    }
                    completion();
                });
            }];
        }
    }];
}

- (void) updateDictWithDict: (NSDictionary *) dict {
    for (NSString *key in [dict allKeys]) {
        if ([self.availableTags objectForKey:key] == nil) {
            [self.availableTags setValue:[dict objectForKey:key] forKey:key];
        }
    }
}
- (NSDictionary *) getTag {
    @synchronized(self) {
        if ([self.availableTags count] == 0) {
            return nil;
        }
        
        NSMutableDictionary *tag = nil;
        NSString *tagKey = nil;
        
        for (int i = 0; i < [self.availableTags count] ; i++) {
            tagKey = [[self.availableTags allKeys] objectAtIndex:i];
            NSData *obj = [self.availableTags objectForKey:tagKey];
            
            if (obj != nil && ![obj isKindOfClass:[NSNull class]]) {
                tag = [NSMutableDictionary dictionary];
                [tag setValue:obj forKey:tagKey];
                
                NSLog(@"\nUsing tag: %@",tagKey);
                [self.availableTags setValue:[NSNull null] forKey:tagKey];
                
                break;
            }
        }
        
        [self saveLocalDatabase:self.availableTags];
        
        NSLog(@"Tag count: %lu",[self.availableTags count]);
        return tag;
    }
}

@end
