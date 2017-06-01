//
//  PGMetarOfflineTagManager.m
//  Sprocket
//
//  Created by Fernando Caprio on 6/1/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarOfflineTagManager.h"
#import "PGMetarAPI.h"

#define kOfflineTagSaveName @"OFFLINE_TAG_METAR"

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

- (NSDictionary *) fetchLocalDatabase {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *offlineTagDict = [defaults dictionaryForKey:kOfflineTagSaveName];
    
    if (offlineTagDict == nil) {
        offlineTagDict = [NSDictionary dictionary];
    }
    
    return offlineTagDict;
}

- (void) saveLocalDatabase: (NSDictionary *) dict {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dict forKey:kOfflineTagSaveName];
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
                    NSDictionary *offlineDict = [self fetchLocalDatabase];
                    
                    NSMutableDictionary *updatedDict = [NSMutableDictionary dictionaryWithDictionary:offlineDict];
                    
                    BOOL needsUpdate = NO;
                    
                    for (NSString *tag in tags) {
                        if ([updatedDict objectForKey:tag] == nil) {
                            
                            UIImage *watermarkedImage = [self downloadImageForTag:tag];
                            if (watermarkedImage != nil) {
                                NSData* imageData = UIImagePNGRepresentation(watermarkedImage);
                                NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject:imageData];
                                
                                [updatedDict setObject:encodedData forKey:tag];
                                needsUpdate = YES;
                            }
                        }
                    }
                    
                    if (needsUpdate) {
                        [self saveLocalDatabase:updatedDict];
                    }
                    
                    completion();
                });
            }];
        }
    }];
}

@end
