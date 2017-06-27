//
//  PGARVideoProcessor.h
//  Sprocket
//
//  Created by Fernando Caprio on 6/26/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGARVideoProcessor : NSObject

- (instancetype)initWithWidth:(float)width height:(float)height fieldOfView:(float)fieldOfView keyPoints:(NSData *)keyPoints descriptors:(NSData *)descriptors;

@end
