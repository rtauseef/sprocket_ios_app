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

#import "MPBTImagePreprocessorManager.h"


@interface MPBTImagePreprocessorManager () <MPBTImageProcessorDelegate>
@property NSUInteger currentIndex;
@property tMPBTImagePreprocessorManagerBlock statusBlock;
@property tMPBTImagePreprocessorManagerCompletionBlock completionBlock;
@property UIImage* currentImage;
@end

@implementation MPBTImagePreprocessorManager



- (instancetype)initWithProcessors:(NSArray *)processors options:(NSDictionary*) options {
    self = [super init];
    if( self ) {
        self.processors = processors;
        self.options = options;
    }
    return self;
}

+ (instancetype)new {
    return [[MPBTImagePreprocessorManager  alloc] init];
}

+ (instancetype)createWithProcessors:(NSArray *)processors options:(NSDictionary*) options{
    return [[MPBTImagePreprocessorManager alloc] initWithProcessors:processors options:options];
}



-(void) processNext {
    if( self.currentIndex >= self.processors.count ) {
        self.completionBlock(nil,self.currentImage);
    } else {
        MPBTImageProcessor * processor = self.processors[(NSUInteger) self.currentIndex];
        processor.delegate = self;
        self.statusBlock(self.currentIndex,0);
        [processor processImage:self.currentImage withOptions:self.options];
    }
}


- (void)processImage:(UIImage *)image statusUpdate:(tMPBTImagePreprocessorManagerBlock)statusUpdate complete:(tMPBTImagePreprocessorManagerCompletionBlock)completion {
    self.currentIndex = 0;
    self.statusBlock = statusUpdate;
    self.completionBlock = completion;
    self.currentImage = image;
    [self processNext];
}




- (void)didCompleteProcessing:(MPBTImageProcessor *)processor result:(UIImage *)image error:(NSError *)error {
    if( error ) {
        self.completionBlock(error,nil);
    } else {
        self.currentIndex++;
        self.currentImage = image;
        [self processNext];
    }
}

- (void)didUpdateProgress:(MPBTImageProcessor *)processor progress:(double)progress {
    self.statusBlock(self.currentIndex, progress);
}

@end
