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
#import <LivePaperSDK/LivePaperSDK.h>
#import <HPLinkUtils/HPLinkUtils.h>
#import "PGWatermarkOperation.h"

/**
 The 'PGWatermarkOperation' is used to embed digital watermarks on images using Link Technology.
 */
@interface PGWatermarkOperationHPLink: HPLinkBaseCompletionOperation<PGWatermarkOperation>

/**
 Executes the operation on a shared queue
 
 @param operationData       The data used to perform the operation
 @param progress            A progress block that will be called with the progress value
 @param completion          A block object to be executed when the watermarking is complete.
 
 */
+ (nullable instancetype)executeWithOperationData:(nonnull PGWatermarkOperationData *)operationData progress:(nullable void (^)(double progress))progress completion:(nullable PGWatermarkEmbedderCompletionBlock)completion;

/**
 Initializes and returns a watemarking operation
 
 @param operationData       The data used to perform the operation
 @param progress            A progress block that will be called with the progress value
 @param completion          A block object to be executed when the watermarking is complete.
 
 */
- (nullable instancetype)initWithOperationData:(nonnull PGWatermarkOperationData *)operationData progress:(nullable void (^)(double progress))progress completion:(nullable PGWatermarkEmbedderCompletionBlock)completion;

@end
