//
//  PGAurasmaMagicFrame.m
//  Sprocket
//
//  Created by Alex Walter on 20/06/2017.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGAurasmaMagicFrame.h"

@implementation PGAurasmaMagicFrame

@synthesize auraId = _auraId;
@synthesize name = _name;
@synthesize imageName = _imageName;

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
