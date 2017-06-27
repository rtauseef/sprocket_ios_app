//
//  PGARLiveProcessor.h
//  Sprocket
//
//  Created by Fernando Caprio on 6/26/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PGMetarArtifact.h"

@interface PGARLiveProcessor : NSObject

- (instancetype) initWithArtifact: (PGMetarArtifact *) artifact andVideoFieldOfView: (float) fieldOfView;
- (void) processSampleBuffer:(CMSampleBufferRef) sampleBuffer;

@end
