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

- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    
    if (self) {
        NSString *artifactType = [dict objectForKey:@"type"];
        
        if (artifactType != nil) {
            if ([artifactType isEqualToString:@"AT_FACE"]) {
                self.type = PGMetarArtifactTypeFace;
            } else if ([artifactType isEqualToString:@"AT_LOGO"]) {
                self.type = PGMetarArtifactTypeLogo;
            } else if ([artifactType isEqualToString:@"AT_OBJECT"]) {
                self.type = PGMetarArtifactTypeObject;
            } else if ([artifactType isEqualToString:@"AT_ORBFEATURE"]) {
                self.type = PGMetarArtifactTypeOrbFeature;
            }
        }
        
        NSString *keypointsBase64 = [dict objectForKey:@"keypoints"];
        NSString *descriptorsBase64 = [dict objectForKey:@"descriptors"];
        
        if (keypointsBase64 && descriptorsBase64) {
            self.keypoints = [[NSData alloc] initWithBase64EncodedString:keypointsBase64 options:0];
            self.descriptors = [[NSData alloc] initWithBase64EncodedString:descriptorsBase64 options:0];
        }
        
        NSDictionary *bounds = [dict objectForKey:@"bounds"];
        
        if (bounds) {
            self.bounds = CGRectMake([[bounds objectForKey:@"left"] floatValue], [[bounds objectForKey:@"top"] floatValue], [[bounds objectForKey:@"width"] floatValue], [[bounds objectForKey:@"height"] floatValue]);
        }
    }
    
    return self;
}

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    switch (self.type) {
        case PGMetarArtifactTypeFace:
            [dict setObject:@"AT_FACE" forKey:@"type"];
            break;
        case PGMetarArtifactTypeLogo:
            [dict setObject:@"AT_LOGO" forKey:@"type"];
            break;
        case PGMetarArtifactTypeObject:
            [dict setObject:@"AT_OBJECT" forKey:@"type"];
            break;
        case PGMetarArtifactTypeOrbFeature:
            [dict setObject:@"AT_ORBFEATURE" forKey:@"type"];
        default:
            break;
    }
    
    if (self.keypoints && self.descriptors && !CGRectIsEmpty(self.bounds)) {
        NSString *base64Keypoints = [self.keypoints base64EncodedStringWithOptions:0];
        [dict setObject:base64Keypoints forKey:@"keypoints"];
        
        NSString *base64Descriptors = [self.descriptors base64EncodedStringWithOptions:0];
        [dict setObject:base64Descriptors forKey:@"descriptors"];
        
        NSMutableDictionary *imageBounds = [NSMutableDictionary dictionary];
        [imageBounds setObject:[NSNumber numberWithFloat:self.bounds.origin.y] forKey:@"top"];
        [imageBounds setObject:[NSNumber numberWithFloat:self.bounds.origin.x] forKey:@"left"];
        [imageBounds setObject:[NSNumber numberWithFloat:self.bounds.size.height] forKey:@"height"];
        [imageBounds setObject:[NSNumber numberWithFloat:self.bounds.size.width] forKey:@"width"];
        
        [dict setObject:imageBounds forKey:@"bounds"];
    }
    
    return dict;
}

@end
