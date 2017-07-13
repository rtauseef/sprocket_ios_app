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

@interface PGPartyAWSTransfer()

@property (nonatomic, readonly) dispatch_queue_t uploadQueue;
@property (nonatomic, readonly) dispatch_queue_t downloadQueue;

@end

@implementation PGPartyAWSTransfer

static NSString * const kPoolId = @"us-west-2:131f9801-8177-4c2f-be31-af753d4ee886";
static NSString * const kBucketName = @"cloud-transfer-temp";

static NSString * const kUploadFile = @"upload.jpg";
static NSString * const kDownloadFile = @"download.jpg";

static char * const kUploadQueue = "com.hp.sprocket.queue.party.upload";
static char * const kDownloadQueue = "com.hp.sprocket.queue.party.download";

static int const kFileIdLength = 10;

#pragma mark - Initialization

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static PGPartyAWSTransfer *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGPartyAWSTransfer alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uploadQueue = dispatch_queue_create(kUploadQueue, NULL);
        _downloadQueue = dispatch_queue_create(kDownloadQueue, NULL);
        [self configure];
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

- (void)upload:(PGPartyFileInfo *)info progress:(void (^_Nonnull)(NSUInteger bytesSent))progress completion:(void (^_Nonnull)(NSError *error))completion
{
    PGLogDebug(@"AWS UPLOAD: %lu: START", (unsigned long)info.identifier);

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
    
    AWSExecutor *executor = [AWSExecutor executorWithDispatchQueue:self.uploadQueue];
    [[transferManager upload:uploadRequest] continueWithExecutor:executor withBlock:^id(AWSTask *task) {
        if (task.error) {
            [self deleteFile:url];
            PGLogError(@"AWS UPLOAD: %lu: ERROR: %@", (unsigned long)info.identifier, task.error);
        }
        
        if (task.result) {
            [self deleteFile:url];
            completion(task.error);
            PGLogInfo(@"AWS UPLOAD: %lu: COMPLETE", (unsigned long)info.identifier);
        }
        return nil;
    }];
}

- (void)download:(PGPartyFileInfo *)info progress:(void (^_Nonnull)(NSUInteger bytesReceived))progress completion:(void (^_Nonnull)(UIImage *image, NSError *error))completion
{
    PGLogDebug(@"AWS DOWNLOAD: %lu: START", (unsigned long)info.identifier);

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
    
    AWSExecutor *executor = [AWSExecutor executorWithDispatchQueue:self.downloadQueue];
    [[transferManager download:downloadRequest ] continueWithExecutor:executor withBlock:^id(AWSTask *task) {
        if (task.error){
            [self deleteFile:url];
            PGLogError(@"AWS DOWNLOAD: %lu: ERROR: %@", (unsigned long)info.identifier, task.error);
        }
        
        if (task.result) {
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [self deleteFile:url];
            completion(image, task.error);
            PGLogInfo(@"AWS DOWNLOAD: %lu: COMPLETE: %@", (unsigned long)info.identifier, image);
        }
        
        return nil;
    }];
}

#pragma mark - Utility

- (void)deleteFile:(NSURL *)url
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (error) {
        PGLogError(@"DELETE FILE ERROR: %@", error);
    }
}

@end
