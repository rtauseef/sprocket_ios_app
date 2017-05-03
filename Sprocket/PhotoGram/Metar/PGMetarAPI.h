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
- (void) watermarkImage;
- (void) setImageMetadata;
- (void) requestImageMetadata;
- (void) requestImageMetadataWithFilter;

// future
- (void) requestOfflineTags;
- (void) downloadImage;

@end
