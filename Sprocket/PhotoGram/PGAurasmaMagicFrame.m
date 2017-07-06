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

#import "PGAurasmaMagicFrame.h"

@implementation PGAurasmaMagicFrame

+ (instancetype) magicFrameWithAuraId:(NSString *) auraId
                                 name:(NSString *) name
                            imageName:(NSString *) imageName {
    return [[PGAurasmaMagicFrame alloc] initWithAuraId:auraId name:name imageName:imageName];
}

- (instancetype) initWithAuraId:(NSString *) auraId
                           name:(NSString *) name
                      imageName:(NSString *) imageName {
    self = [super init];
    
    if (self) {
        _auraId = auraId;
        _name = name;
        _imageName = imageName;
    }
    
    return self;
}

@end
