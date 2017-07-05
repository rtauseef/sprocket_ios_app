//
//  PGAurasmaMagicFrame.h
//  Sprocket
//
//  Created by Alex Walter on 20/06/2017.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGAurasmaMagicFrame : NSObject

+ (instancetype) magicFrameWithAuraId:(NSString *) auraId
                                 name:(NSString *) name
                            imageName:(NSString *) imageName;

@property (readonly, nonatomic) NSString *auraId;

@property (readonly, nonatomic) NSString *name;

@property (readonly, nonatomic) NSString *imageName;

@end
