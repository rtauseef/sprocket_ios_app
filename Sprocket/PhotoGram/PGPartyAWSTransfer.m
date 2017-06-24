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

#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSS3/AWSS3.h>

#import "PGPartyAWSTransfer.h"

@implementation PGPartyAWSTransfer
{
    dispatch_queue_t _uploadQueue;
    dispatch_queue_t _downloadQueue;
}

static NSString *kPoolId = @"us-west-2:131f9801-8177-4c2f-be31-af753d4ee886";
static NSString *kBucketName = @"cloud-transfer-temp";

static NSString *kUploadFile = @"upload.jpg";
static NSString *kDownloadFile = @"download.jpg";

static char *kUploadQueue = "com.hp.sprocket.queue.party.upload";
static char *kDownloadQueue = "com.hp.sprocket.queue.party.download";

static int kFileIdLength = 10;

#pragma mark - Initialization

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static PGPartyAWSTransfer *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGPartyAWSTransfer alloc] init];
        [sharedInstance configure];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uploadQueue = dispatch_queue_create(kUploadQueue, NULL);
        _downloadQueue = dispatch_queue_create(kDownloadQueue, NULL);
    }
    return self;
}

- (void)configure
{
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSWest2 identityPoolId:kPoolId];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

#pragma mark - Transfer

- (void)upload:(PGPartyFileInfo *)info progress:(void (^)(NSUInteger bytesSent))progress completion:(void (^)(NSError *error))completion
{
    NSLog(@"AWS UPLOAD: %lu: START", (unsigned long)info.identifier);

    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    NSString *key = [NSString stringWithFormat:@"%0*lu", kFileIdLength, (unsigned long)info.identifier];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
    NSURL *url = [NSURL fileURLWithPath:path];

    [self deleteFile:url];

    [info.data writeToFile:path atomically:YES];

    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = kBucketName;
    uploadRequest.key = key;
    uploadRequest.body = url;
    uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        progress((NSUInteger)totalBytesSent);
    };
    
    AWSExecutor *executor = [AWSExecutor executorWithDispatchQueue:_uploadQueue];
    [[transferManager upload:uploadRequest] continueWithExecutor:executor withBlock:^id(AWSTask *task) {
        if (task.error) {
            [self deleteFile:url];
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                    default:
                        NSLog(@"AWS UPLOAD: %lu: TASK ERROR: %@", (unsigned long)info.identifier, task.error);
                        break;
                }
            } else {
                NSLog(@"AWS UPLOAD: %lu: ERROR: %@", (unsigned long)info.identifier, task.error);
            }
        }
        
        if (task.result) {
            [self deleteFile:url];
            completion(task.error);
            NSLog(@"AWS UPLOAD: %lu: COMPLETE", (unsigned long)info.identifier);
        }
        return nil;
    }];
}

- (void)download:(PGPartyFileInfo *)info progress:(void (^)(NSUInteger bytesReceived))progress completion:(void (^)(UIImage *image, NSError *error))completion
{
    NSLog(@"AWS DOWNLOAD: %lu: START", (unsigned long)info.identifier);

    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];

    NSString *key = [NSString stringWithFormat:@"%0*lu", kFileIdLength, (unsigned long)info.identifier];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    [self deleteFile:url];
    
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    downloadRequest.bucket = kBucketName;
    downloadRequest.key = key;
    downloadRequest.downloadingFileURL = url;
    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
        progress((NSUInteger)totalBytesWritten);
    };
    
    AWSExecutor *executor = [AWSExecutor executorWithDispatchQueue:_downloadQueue];
    [[transferManager download:downloadRequest ] continueWithExecutor:executor withBlock:^id(AWSTask *task) {
        if (task.error){
            [self deleteFile:url];
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                    default:
                        NSLog(@"AWS DOWNLOAD: %lu: TASK ERROR: %@", (unsigned long)info.identifier, task.error);
                        break;
                }
                
            } else {
                NSLog(@"AWS DOWNLOAD: %lu: ERROR: %@", (unsigned long)info.identifier, task.error);
            }
        }
        
        if (task.result) {
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [self deleteFile:url];
            completion(image, task.error);
            NSLog(@"AWS DOWNLOAD: %lu: COMPLETE: %@", (unsigned long)info.identifier, image);
        }
        
        return nil;
    }];
}

#pragma mark - Utility

- (void)deleteFile:(NSURL *)url
{
//    NSError *error = nil;
//    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
//    if (error) {
//        NSLog(@"DELETE FILE ERROR: %@", error);
//    }
}

@end
