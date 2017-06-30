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
#import <AVFoundation/AVFoundation.h>
#import <SceneKit/SceneKit.h>
#import "PGARVideoProcessorResult.h"

@interface PGARVideoProcessor : NSObject

@property BOOL enableFilter;
@property (assign, nonatomic) SCNMatrix4 projection;

- (instancetype)initWithArtifactSize:(CGSize)artifactSize videoSize:(CGSize)dim renderSize:(CGSize) renderSize fieldOfView:(float)fieldOfView keyPoints:(NSData *)keyPoints descriptors:(NSData *)descriptors;
- (void)runTracker:(CMSampleBufferRef)sampleBuffer completion:(nullable void (^)(PGARVideoProcessorResult *res)) completion;
+(CGRect) calcTargetVideoRect:(CGSize) videoSize inView:(CGSize) viewSize;

@end
