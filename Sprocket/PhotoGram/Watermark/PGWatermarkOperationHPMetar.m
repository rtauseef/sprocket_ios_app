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

#import "PGWatermarkOperationHPMetar.h"
#import "PGMetarAPI.h"
#import "PGMetarOfflineTagManager.h"
#import "PGLinkSettings.h"
#import "PGARImageProcessor.h"

static const NSString * PGWatermarkEmbedderDomainMetar = @"com.hp.sprocket.watermarkembedder.metar";
static const NSInteger kTotalAuthRetries = 3;
static const NSInteger kMiniumTagsInLocalDb = 5;

@interface PGWatermarkOperationHPMetar ()

@property (nonatomic, copy, nullable) void (^progressCallback)(double progress);
@property (strong, nonatomic) PGWatermarkOperationData *operationData;
@property (assign, nonatomic) NSInteger currentAuthRetry;

@end

@implementation PGWatermarkOperationHPMetar

+ (instancetype)executeWithOperationData:(nonnull PGWatermarkOperationData *)operationData progress:(nullable void (^)(double progress))progress completion:(nullable PGWatermarkEmbedderCompletionBlock)completion {
    
    PGWatermarkOperationHPMetar *operation = [[self alloc] init];
    operation.operationData = operationData;
    operation.progressCallback = progress;
    operation.currentAuthRetry = 0;
    
    if ([PGLinkSettings videoAREnabled]) {
        PGARImageProcessor *arProcessor = [[PGARImageProcessor alloc] init];
        PGMetarMedia *metadata = operationData.metadata;
        
        PGMetarArtifact *ORBArtifact;
        ORBArtifact = [arProcessor createORBPatternArtifact:operationData.originalImage];
        
        if (ORBArtifact != nil) {
            NSMutableArray *updatedArtifactArray = [NSMutableArray array];
            
            if (metadata.artifacts != nil && [metadata.artifacts count] > 0) {
                [updatedArtifactArray addObjectsFromArray:metadata.artifacts];
            }
            
            [updatedArtifactArray addObject:ORBArtifact];
            
            metadata.artifacts = updatedArtifactArray;
            operation.operationData.metadata = metadata;
        }
    }
    
    if ([PGLinkSettings localWatermarkEnabled]) {
        [operation executeOffline:completion];
    } else {
        [operation execute:completion];
    }
    
    return operation;
}

- (void) handleCallback: (nullable void (^) (UIImage *  image, NSError *  error)) completion image:(UIImage *) image error: (NSError *) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.progressCallback) {
            self.progressCallback(1);
        }
        
        if (completion) {
            completion(image,error);
        }
    });
}

- (void) updateProgress: (double) value {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressCallback) {
            self.progressCallback(value);
        }
    });
}

//TODO: better progress callback, using http download/upload progress
- (void) execute: (nullable PGWatermarkEmbedderCompletionBlock)completion {
    PGMetarAPI *api = [[PGMetarAPI alloc] init];
    
    [api authenticate:^(BOOL success) {
        if (success) {
            [self updateProgress: 0.2];
            
            [api uploadImage:self.operationData.originalImage completion:^(NSError * _Nullable error, PGMetarImageTag * _Nullable imageTag) {
                if (error == nil) {
                    
                    [self updateProgress: 0.7];
                    
                    [api downloadWatermarkedImage:imageTag completion:^(NSError * _Nullable error, UIImage * _Nullable watermarkedImage) {
                        if (error == nil) {
                            [api setImageMetadata:imageTag mediaMetada:self.operationData.metadata completion:^(NSError * _Nullable error) {
                                if (error == nil) {
                                    [self handleCallback:completion image:watermarkedImage error:error];
                                } else {
                                    [self handleCallback:completion image:nil error:error];
                                }
                            }];
                        } else {
                            [self handleCallback:completion image:nil error:error];
                        }
                    }];
                    
                } else {
                    ++self.currentAuthRetry;
                    
                    if (error.code == PGMetarAPIErrorRequestFailedAuth && self.currentAuthRetry <= kTotalAuthRetries) {
                        [self execute: completion];
                    } else {
                        [self handleCallback:completion image:nil error:error];
                    }
                }
            }];
        } else {
            [self handleCallback:completion image:nil error: [NSError errorWithDomain:PGWatermarkEmbedderDomainMetar code:PGWatermarkEmbedderErrorInputsErrorAPIAuth userInfo:@{ NSLocalizedDescriptionKey: @"API Auth Error."}]];
        }
    }];
}

- (void) runLocalWatermark: (nullable PGWatermarkEmbedderCompletionBlock) completion {
    [self updateProgress: 0.3];
    
    PGMetarOfflineTagManager *tagMgr = [PGMetarOfflineTagManager sharedInstance];
    NSDictionary *tagDict = [tagMgr getTag];
    
    if ([tagMgr tagCount] == 0) {
        // failed
        [self handleCallback:completion image:nil error: [NSError errorWithDomain:PGWatermarkEmbedderDomainMetar code:PGWatermarkEmbedderErrorInputsErrorAPIAuth userInfo:@{ NSLocalizedDescriptionKey: @"Failed to get additional tags."}]];
    } else {
        // good to go
        [self updateProgress: 0.6];
        
        UIImage *originalImage = self.operationData.originalImage;
        NSString *tag = [[tagDict allKeys] firstObject];
        NSData *watermarkData = [tagDict valueForKey:tag];
        UIImage *watermark = [UIImage imageWithData:watermarkData];
        
        CGSize size = originalImage.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 1);
        
        [originalImage drawAtPoint:CGPointZero];
        int x = 0;
        int y = 0;
        
        while (y < originalImage.size.height) {
            CGPoint point = CGPointMake(x, y);
            [watermark drawAtPoint:point blendMode:kCGBlendModeOverlay alpha:1.0];
            
            if (x + watermark.size.width < originalImage.size.width) {
                x += watermark.size.width;
            } else {
                x = 0;
                y += watermark.size.height;
            }
        }
        
        UIImage* blendedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        PGMetarAPI *api = [[PGMetarAPI alloc] init];
        PGMetarImageTag *imageTag = [[PGMetarImageTag alloc] init];
        imageTag.resource = tag;
        
        [self updateProgress: 0.8];
        
        [api setImageMetadata:imageTag mediaMetada:self.operationData.metadata completion:^(NSError * _Nullable error) {
            if (error == nil) {
                [self handleCallback:completion image:blendedImage error:nil];
            } else {
                [self handleCallback:completion image:nil error:error];
            }
        }];
    }
}
    
- (void) executeOffline: (nullable PGWatermarkEmbedderCompletionBlock)completion {
    PGMetarOfflineTagManager *tagMgr = [PGMetarOfflineTagManager sharedInstance];
    

    if ([tagMgr tagCount] < kMiniumTagsInLocalDb) {
        [tagMgr checkTagDB:^{
            [self runLocalWatermark:completion];
        }];
    } else {
        [self runLocalWatermark:completion];
    }
}


@end
