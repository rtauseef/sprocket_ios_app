//
//  PGWatermarkOperationHPMetar.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/3/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGWatermarkOperationHPMetar.h"
#import "PGMetarAPI.h"
#import "PGMetarOfflineTagManager.h"
#import "PGLinkSettings.h"

NSString * const PGWatermarkEmbedderDomainMetar = @"com.hp.sprocket.watermarkembedder.metar";
#define kTotalAuthRetries 3
#define kMiniumTagsInLocalDb 5

@interface PGWatermarkOperationHPMetar ()

@property (nonatomic, copy, nullable) void (^progressCallback)(double progress);
@property (strong, nonatomic) PGWatermarkOperationData *operationData;
@property (assign, nonatomic) int currentAuthRetry;

@end

@implementation PGWatermarkOperationHPMetar

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (nullable instancetype)executeWithOperationData:(nonnull PGWatermarkOperationData *)operationData progress:(nullable void (^)(double progress))progress completion:(nullable PGWatermarkEmbedderCompletionBlock)completion {
    
    PGWatermarkOperationHPMetar *operation = [[self alloc] init];
    operation.operationData = operationData;
    operation.progressCallback = progress;
    operation.currentAuthRetry = 0;
    
    if ([PGLinkSettings localWatermarkEnabled]) {
        [operation executeOffline:completion];
    } else {
        [operation execute:completion];
    }
    
    return operation;
}

- (void) handleCallback: (nullable void (^) (UIImage *  image, NSError *  error)) completion image:(UIImage *) image error: (NSError *) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressCallback(1);
        completion(image,error);
    });
}

- (void) updateProgress: (double) value {
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressCallback(value);
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
