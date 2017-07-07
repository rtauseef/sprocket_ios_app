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

#import "PGCloudAssetDownloadWorker.h"

NSString * const kCloudAssetDownloadWorkerDownloadComplete = @"com.hp.sprocket.cloud-asset.download-complete";

@interface PGCloudAssetDownloadWorker ()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation PGCloudAssetDownloadWorker

+ (instancetype)sharedInstance
{
    static PGCloudAssetDownloadWorker *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PGCloudAssetDownloadWorker alloc] init];
    });

    return instance;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.downloadQueue = [[NSOperationQueue alloc] init];
    }

    return self;
}

- (void)scheduleAssetDownload:(PGCloudAssetImage *)asset
{

}

- (void)start
{

}

- (void)pause
{

}

- (void)stop
{
    [self.downloadQueue cancelAllOperations];
}

- (NSInteger)queueSize
{
    return [self.downloadQueue operationCount];
}

#pragma mark - Private

@end
