//
//  PGMetarAPI.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/3/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMetarAPI : NSObject

typedef NS_ENUM(NSInteger, PGMetarAPIError) {
    PGMetarAPIErrorRequestFailed
};

- (void) authenticate: (nullable void (^)(BOOL success)) completion;
- (void) challenge: (nullable void (^)(NSError * _Nullable error)) completion;
- (void) getAccessToken: (nullable void (^)(NSError * _Nullable error)) completion;


// TODO: implement
- (void) watermarkImage;
- (void) setImageMetadata;
- (void) requestImageMetadata;
- (void) requestImageMetadataWithFilter;

// TODO: implement when available, future spec
- (void) requestOfflineTags;
- (void) downloadImage;

@end
