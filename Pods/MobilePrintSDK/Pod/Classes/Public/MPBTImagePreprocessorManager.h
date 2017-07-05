//
// HP Inc.
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
#import "MPBTImageProcessor.h"

typedef void (^tMPBTImagePreprocessorManagerBlock)(NSUInteger processorIndex, double progress);
typedef void (^tMPBTImagePreprocessorManagerCompletionBlock)(NSError *error, UIImage *image);

@interface MPBTImagePreprocessorManager : NSObject

@property (strong, nonatomic) NSArray *processors;
@property (strong, nonatomic) NSDictionary *options;

+ (instancetype)createWithProcessors:(NSArray *)processors options:(NSDictionary *)options;

- (instancetype)initWithProcessors:(NSArray *)processors options:(NSDictionary *)options;
- (void)processImage:(UIImage *)image statusUpdate:(tMPBTImagePreprocessorManagerBlock)statusUpdate complete:(tMPBTImagePreprocessorManagerCompletionBlock)completion;

@end
