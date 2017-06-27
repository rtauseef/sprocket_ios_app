//
//  PGARVideoProcessorResult.h
//  Sprocket
//
//  Created by Fernando Caprio on 6/27/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <SceneKit/SceneKit.h>

@interface PGARVideoProcessorResult : NSObject

@property (assign, nonatomic) BOOL transAvailable;
@property (assign, nonatomic) SCNMatrix4 trans;
@property (strong, nonatomic) CIImage *videoFrame;

@end
