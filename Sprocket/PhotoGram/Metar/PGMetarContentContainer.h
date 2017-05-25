//
//  PGContentContainer.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMetarImageItem.h"

@interface PGMetarContentContainer : NSObject

@property (strong, nonatomic) NSDate* updatedAt;
@property (strong, nonatomic) NSArray* pages;
@property (strong, nonatomic) NSArray<PGMetarImageItem*>* imagelist;

- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end
