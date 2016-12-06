//
//  PGWatemarkImageOperation.h
//  Sprocket
//
//  Created by Live Paper Pairing on 12/6/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCompletionOperation.h"

typedef NS_ENUM(NSInteger, PGWatermarkEmbedderError) {
    PGWatermarkEmbedderErrorWatermarkingImage = 100,
    PGWatermarkEmbedderWatermarkingTimeout = 101
};

typedef void (^PGWatermarkEmbedderCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error);

/**
 The 'PGWatemarkImageOperation' is used to embed digital watermarks on images using Link Technology.
 */
@interface PGWatemarkImageOperation : BaseCompletionOperation

/**
 Executes the operation on a shared queue
 
 @param image An image to be watemarked.
 @param block A block object to be executed when the watermarking is complete.
 
 */
+ (nullable instancetype)executeWithImage:(nonnull UIImage *)image completion:(nullable PGWatermarkEmbedderCompletionBlock)completion;

/**
 Initializes and returns a watemarking operation
 
 @param image An image to be watemarked.
 @param block A block object to be executed when the watermarking is complete.
 
 */
- (nullable instancetype)initWithImage:(nonnull UIImage *)image queue:(nonnull OperationQueue *)queue completion:(nullable PGWatermarkEmbedderCompletionBlock)completion;


+ (nullable instancetype)executeWithData:(nullable id)operationData completion:(nullable BaseOperationCompletion)completion NS_UNAVAILABLE;
- (nullable instancetype)initWithData:(nullable id)operationData queue:(nonnull OperationQueue *)queue completion:(nullable BaseOperationCompletion)completion NS_UNAVAILABLE;

@end
