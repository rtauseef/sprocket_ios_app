//
//  PGMetarAPI.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/3/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMetarImageTag.h"
#import "PGMetarMedia.h"

@interface PGMetarAPI : NSObject

typedef NS_ENUM(NSInteger, PGMetarAPIError) {
    PGMetarAPIErrorRequestFailed,
    PGMetarAPIErrorCreatingJsonForMediaObject,
    PGMetarAPIErrorEmptyPayload,
    PGMetarAPIErrorFailedParsingPayload,
};

#define kBatataAPIURL @"http://www.somacoding.com/sprocket-link"
#define kMetarAPIURL @"http://www.somacoding.com/metar"

- (void) authenticate: (nullable void (^)(BOOL success)) completion;
- (void) challenge: (nullable void (^)(NSError * _Nullable error)) completion;
- (void) getAccessToken: (nullable void (^)(NSError * _Nullable error)) completion;
- (void) uploadImage: (UIImage *_Nullable) image completion: (nullable void (^)(NSError * _Nullable error, PGMetarImageTag * _Nullable imageTag)) completion;
- (void) downloadWatermarkedImage: (PGMetarImageTag *_Nonnull) imageTag completion: (nullable void (^)(NSError * _Nullable error, UIImage * _Nullable watermarkedImage)) completion;
- (void) setImageMetadata: (PGMetarImageTag *_Nonnull) imageTag mediaMetada:(PGMetarMedia *_Nonnull) metadata completion: (nullable void (^)(NSError * _Nullable error)) completion;
- (void) requestImageMetadataWithUUID: (NSString *_Nonnull) uuid completion: (nullable void (^)(NSError * _Nullable error, PGMetarMedia * _Nullable metarMedia)) completion;

// TODO: implement
- (void) requestImageMetadataWithFilter;

// TODO: implement when available, future spec
- (void) requestOfflineTags;
- (void) downloadImage;

@end
