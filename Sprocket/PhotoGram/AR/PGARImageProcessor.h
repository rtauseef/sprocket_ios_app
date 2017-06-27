//
//  PGARImageProcessor.h
//  Sprocket
//
//  Created by Fernando Caprio on 6/26/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMetarArtifact.h"

@interface PGARImageProcessor : NSObject

-(PGMetarArtifact *) createORBPatternArtifact:(UIImage*) image;

@end
