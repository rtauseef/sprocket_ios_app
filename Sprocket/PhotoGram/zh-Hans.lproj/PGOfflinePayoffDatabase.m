//
//  PGOfflinePayoffDatabase.m
//  Sprocket
//
//  Created by Bruno Dal Bo on 4/17/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGOfflinePayoffDatabase.h"
#import "PGPayoffMetadata.h"

static NSString * const kOfflineMetadataUserDefaultsKey = @"pg-payoff-offline-meta";

@implementation PGOfflinePayoffDatabase




+(instancetype) sharedInstance {
    static PGOfflinePayoffDatabase * shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PGOfflinePayoffDatabase alloc] init];
    });
    return shared;
}

- (void)saveMetadata:(PGPayoffMetadata *)meta {
    // TODO saving metadata to user defaults for the time being. Using core data is more performatic
    // TODO saved metadata is being kept forever, strategy to delete olf metadata may be interesting to prevent exploding local database

    NSMutableDictionary * data = [[[NSUserDefaults standardUserDefaults] objectForKey:kOfflineMetadataUserDefaultsKey] mutableCopy];
    if( ! data ) {
        data = [NSMutableDictionary dictionary];
    }
    data[meta.uuid] = [meta toDictionary]; // save all data
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kOfflineMetadataUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (PGPayoffMetadata *)loadMetadata:(NSString *)id {
    NSDictionary * data = [[NSUserDefaults standardUserDefaults] objectForKey:kOfflineMetadataUserDefaultsKey];
    if( data ) {
        NSDictionary *  entry = data[id];
        if( entry ) {
            return [PGPayoffMetadata offlinePayoffWithDictionary:entry];
        }
    }

    return nil;

}


@end
