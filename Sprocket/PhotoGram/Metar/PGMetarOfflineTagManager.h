//
//  PGMetarOfflineTagManager.h
//  Sprocket
//
//  Created by Fernando Caprio on 6/1/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarOfflineTagManager : NSObject

+ (PGMetarOfflineTagManager *_Nonnull)sharedInstance;
- (void) checkTagDB: (nullable void (^)()) completion;
- (NSDictionary *_Nullable) fetchLocalDatabase;
- (void) saveLocalDatabase: (NSDictionary *_Nonnull) dic;
- (NSDictionary *_Nullable) getTag;
- (int) tagCount;


@end
