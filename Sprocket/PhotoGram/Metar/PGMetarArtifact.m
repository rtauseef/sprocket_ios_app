//
//  PGMetarArtifact.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/5/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarArtifact.h"

@implementation PGMetarArtifact

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    switch (self.type) {
        case PGMetarArtifactTypeFace:
            [dict setObject:@"face" forKey:@"type"];
            break;
        case PGMetarArtifactTypeLogo:
            [dict setObject:@"logo" forKey:@"type"];
            break;
        case PGMetarArtifactTypeObject:
            [dict setObject:@"object" forKey:@"type"];
            break;
        default:
            break;
    }
    
    return dict;
}

@end
