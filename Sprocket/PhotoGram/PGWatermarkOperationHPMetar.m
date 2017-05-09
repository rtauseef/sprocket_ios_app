//
//  PGWatermarkOperationHPMetar.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/3/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGWatermarkOperationHPMetar.h"
#import "PGMetarAPI.h"

NSString * const PGWatermarkEmbedderDomainMetar = @"com.hp.sprocket.watermarkembedder.metar";

@interface PGWatermarkOperationHPMetar ()

@property (nonatomic, copy, nullable) void (^progressCallback)(double progress);
@property (strong, nonatomic) PGWatermarkOperationData *operationData;

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
    [operation execute:completion];
    
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
                            [api setIMageMetadata:imageTag mediaMetada:self.operationData.metadata completion:^(NSError * _Nullable error) {
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
                    [self handleCallback:completion image:nil error:error];
                }
            }];
        } else {
            [self handleCallback:completion image:nil error: [NSError errorWithDomain:PGWatermarkEmbedderDomainMetar code:PGWatermarkEmbedderErrorInputsErrorAPIAuth userInfo:@{ NSLocalizedDescriptionKey: @"API Auth Error."}]];
        }
    }];
}

@end
