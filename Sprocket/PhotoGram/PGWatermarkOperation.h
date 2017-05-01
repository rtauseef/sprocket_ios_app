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

extern NSString * _Nonnull const PGWatermarkEmbedderDomain;

typedef NS_ENUM(NSInteger, PGWatermarkEmbedderError) {
    PGWatermarkEmbedderErrorInputsError,
    PGWatermarkEmbedderErrorWatermarkingImage,
    PGWatermarkEmbedderErrorWatermarkingImageNoInternet,
    PGWatermarkEmbedderWatermarkingTimeout
};

typedef void (^PGWatermarkEmbedderCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error);

/**
 The data used to execute a 'PGWatermarkOperation' operation.
 */
@interface PGWatermarkOperationData : NSObject
// An image to be watemarked
@property (nonatomic, nonnull) UIImage *originalImage;
// The identifier of the device to which the watermark data will be associated to
@property (nonatomic, nonnull) NSString *printerIdentifier;
// The URL that will be shown when the image is scanned
@property (nonatomic, nonnull) NSURL *payoffURL;
@end


/**
 The 'PGWatermarkOperation' is used to embed digital watermarks on images using Link Technology.
 */
@interface PGWatermarkOperation : HPLinkBaseCompletionOperation

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
