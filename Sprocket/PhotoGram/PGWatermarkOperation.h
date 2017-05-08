//
//  PGWatermarkOperation.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/3/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGWatermarkOperationData.h"

@protocol PGWatermarkOperation

typedef void (^PGWatermarkEmbedderCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error);

typedef NS_ENUM(NSInteger, PGWatermarkEmbedderError) {
    PGWatermarkEmbedderErrorInputsError,
    PGWatermarkEmbedderErrorWatermarkingImage,
    PGWatermarkEmbedderErrorWatermarkingImageNoInternet,
    PGWatermarkEmbedderErrorInputsErrorAPIAuth,
    PGWatermarkEmbedderWatermarkingTimeout
};

@required

+ (nullable instancetype)executeWithOperationData:(nonnull PGWatermarkOperationData *)operationData progress:(nullable void (^)(double progress))progress completion:(nullable PGWatermarkEmbedderCompletionBlock)completion;

@end
