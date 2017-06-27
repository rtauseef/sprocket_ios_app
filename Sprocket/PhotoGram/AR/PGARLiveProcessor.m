//
//  PGARLiveProcessor.m
//  Sprocket
//
//  Created by Fernando Caprio on 6/26/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGARLiveProcessor.h"
#import "PGARVideoProcessor.h"

@interface PGARLiveProcessor()

@property (strong, nonatomic) PGARVideoProcessor *videoProcessor;

@end

@implementation PGARLiveProcessor

- (instancetype)initWithArtifact: (PGMetarArtifact *) artifact andVideoFieldOfView: (float) fieldOfView
{
    self = [super init];
    if (self) {
        self.videoProcessor = [[PGARVideoProcessor alloc] initWithWidth:artifact.bounds.size.width height:artifact.bounds.size.height fieldOfView:fieldOfView keyPoints:artifact.keypoints descriptors:artifact.descriptors];
    }
    return self;
}
- (void) processSampleBuffer: (CMSampleBufferRef) sampleBuffer {
    
}

@end
