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

#import "PGWatermarkProcessor.h"

@interface PGWatermarkProcessor()

@property (assign, nonatomic) BOOL finishedWatermarking;

@end

@implementation PGWatermarkProcessor

- (instancetype)initWithWatermarkURL:(NSURL *)url
{
    if (self = [self init]) {
        _watermarkURL = url;
    }
    return self;
}

- (NSString *)name
{
    return @"Watermark";
}

- (NSString *)progressText
{
    return @"Watermarking image...";
}

- (BOOL)completed
{
    return self.finishedWatermarking;
}

- (void)processImage:(UIImage *)image withOptions:(NSDictionary *)options
{
    // TODO:jbt: finish this
    
    self.finishedWatermarking = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCompleteProcessing:result:error:)]) {
        [self.delegate didCompleteProcessing:self result:image error:nil];
    }
}

@end
