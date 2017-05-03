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
    operation.progressCallback = progress;
    [operation execute:completion];
    
    return operation;
}

- (void) execute: (nullable PGWatermarkEmbedderCompletionBlock)completion {
    PGMetarAPI *api = [[PGMetarAPI alloc] init];
    [api authenticate:^(BOOL success) {
        completion(nil, [NSError errorWithDomain:PGWatermarkEmbedderDomainMetar code:PGWatermarkEmbedderErrorInputsError userInfo:@{ NSLocalizedDescriptionKey: @"Invalid operation data."}]);
    
    }];
}

@end
