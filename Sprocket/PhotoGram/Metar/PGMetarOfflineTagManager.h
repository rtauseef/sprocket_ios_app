//
//  PGMetarOfflineTagManager.h
//  Sprocket
//
//  Created by Fernando Caprio on 6/1/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarOfflineTagManager : NSObject

+ (PGMetarOfflineTagManager *)sharedInstance;
- (void) checkTagDB: (nullable void (^)()) completion;

@end
