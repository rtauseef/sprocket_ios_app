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
