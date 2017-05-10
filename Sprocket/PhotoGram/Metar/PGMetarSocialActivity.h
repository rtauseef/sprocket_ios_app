//
//  PGMetarSocialActivity.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/9/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarSocialActivity : NSObject

@property (strong, nonatomic) NSNumber *likes;
@property (strong, nonatomic) NSNumber *shares;
@property (strong, nonatomic) NSNumber *comments;

- (NSDictionary *) getDict;

@end
