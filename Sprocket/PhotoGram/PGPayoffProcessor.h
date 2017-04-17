//
//  PGPayoffProcessor.h
//  Sprocket
//
//  Created by Bruno Dal Bo on 4/17/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PGPayoffMetadata.h"
#import <MPBTImageProcessor.h>

@interface PGPayoffProcessor : MPBTImageProcessor


@property (strong, nonatomic) PGPayoffMetadata * metadata;


- (instancetype)initWithMetadata:(PGPayoffMetadata *)metadata;

+ (instancetype)processorWithMetadata:(PGPayoffMetadata *)metadata;


@end
