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

#import <MPBTImageProcessor.h>
#import "PGWatermarkOperationHPLink.h"

@interface PGWatermarkProcessor : MPBTImageProcessor

@property (strong, nonatomic) NSURL *watermarkURL;

- (instancetype)initWithWatermarkURL:(NSURL *)url;

- (void)processImage:(UIImage *)image withOptions:(NSDictionary *)options completion:(nullable PGWatermarkEmbedderCompletionBlock)completion;

@end
