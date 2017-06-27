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

#import "PGARLiveProcessor.h"
#import "PGARVideoProcessor.h"

@interface PGARLiveProcessor()

@property (strong, nonatomic) PGARVideoProcessor *videoProcessor;

@end

@implementation PGARLiveProcessor

- (instancetype)initWithArtifact: (PGMetarArtifact *) artifact andVideoFieldOfView: (float) fieldOfView andVideoSize: (CGSize) dim
{
    self = [super init];
    if (self) {
        self.videoProcessor = [[PGARVideoProcessor alloc] initWithArtifactSize:artifact.bounds.size videoSize:dim fieldOfView:fieldOfView keyPoints:artifact.keypoints descriptors:artifact.descriptors];
    }
    return self;
}

- (void) processSampleBuffer: (CMSampleBufferRef) sampleBuffer {

    [self.videoProcessor  runTracker:sampleBuffer completion:^(PGARVideoProcessorResult *res) {
        if ([self.delegate respondsToSelector:@selector(displayImage:)]) {
            [self.delegate displayImage:res];
        }
    }];
}

- (SCNMatrix4) getProjection {
    return [self.videoProcessor projection];
}

@end
