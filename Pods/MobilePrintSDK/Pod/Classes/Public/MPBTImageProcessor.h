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

@protocol MPBTImageProcessorDelegate;

@interface MPBTImageProcessor : NSObject

@property (weak, nonatomic) id<MPBTImageProcessorDelegate>delegate;

- (void)processImage:(UIImage *)image withOptions:(NSDictionary *)options;

- (NSString *)name;
- (NSString *)progressText;
- (BOOL)completed;

extern NSString * const kMPBTImageProcessorPrinterSerialNumberKey;

@end

@protocol MPBTImageProcessorDelegate <NSObject>

@optional

- (void)didUpdateProgress:(MPBTImageProcessor *)processor progress:(double)progress;
- (void)didCompleteProcessing:(MPBTImageProcessor *)processor result:(UIImage *)image error:(NSError *)error;

@end
