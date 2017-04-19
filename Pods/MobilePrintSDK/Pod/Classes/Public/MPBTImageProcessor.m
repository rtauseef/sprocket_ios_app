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

#import "MPBTImageProcessor.h"

@implementation MPBTImageProcessor

NSString * const kMPBTImageProcessorPrinterSerialNumberKey = @"kMPBTImageProcessorPrinterIdKey";
NSString * const kMPBTImageProcessorLocalIdentifierKey = @"kMPBTImageProcessorLocalIdentifierIdKey";

- (NSString *)name
{
    return @"Processor";
}

- (NSString *)progressText
{
    return @"Processing...";
}

- (BOOL)completed
{
    return YES;
}

- (void)processImage:(UIImage *)image withOptions:(NSDictionary *)options
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateProgress:progress:)]) {
        [self.delegate didUpdateProgress:self progress:1.0];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCompleteProcessing:result:error:)]) {
        [self.delegate didCompleteProcessing:self result:image error:nil];
    }
}

@end
