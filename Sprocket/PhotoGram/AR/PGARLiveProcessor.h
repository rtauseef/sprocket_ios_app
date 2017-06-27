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
#import "PGMetarArtifact.h"
#import "PGARVideoProcessorResult.h"

@protocol PGARLiveProcessorDelegate <NSObject>

@required
-(void) displayImage:(PGARVideoProcessorResult *) res;

@end

@interface PGARLiveProcessor : NSObject

- (instancetype) initWithArtifact: (PGMetarArtifact *) artifact andVideoFieldOfView: (float) fieldOfView andVideoSize: (CGSize) dim;
- (void) processSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (SCNMatrix4) getProjection;

@property (nonatomic, weak) id<PGARLiveProcessorDelegate> delegate;

@end
