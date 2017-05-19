//
//  PGMetarContent.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMetarContentContainer.h"

@interface PGMetarContent : NSObject

@property (strong, nonatomic) PGMetarContentContainer* wikipedia;

- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end
