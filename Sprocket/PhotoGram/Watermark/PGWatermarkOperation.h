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
