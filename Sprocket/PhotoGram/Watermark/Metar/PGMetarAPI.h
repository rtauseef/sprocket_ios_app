//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import <Foundation/Foundation.h>
#import "PGMetarImageTag.h"
#import "PGMetarMedia.h"

@interface PGMetarAPI : NSObject

typedef NS_ENUM(NSInteger, PGMetarAPIError) {
    PGMetarAPIErrorRequestFailed,
    PGMetarAPIErrorRequestFailedAuth,
    PGMetarAPIErrorCreatingJsonForMediaObject,
    PGMetarAPIErrorEmptyPayload,
    PGMetarAPIErrorFailedParsingPayload,
};

extern NSString * _Nonnull const kMetarAPIURL;
extern NSString * _Nonnull const kBatataAPIURL;

- (void) authenticate: (nullable void (^)(BOOL success)) completion;
- (void) challenge: (nullable void (^)(NSError * _Nullable error)) completion;
- (void) getAccessToken: (nullable void (^)(NSError * _Nullable error)) completion;
- (void) uploadImage: (UIImage *_Nullable) image completion: (nullable void (^)(NSError * _Nullable error, PGMetarImageTag * _Nullable imageTag)) completion;
- (void) downloadWatermarkedImage: (PGMetarImageTag *_Nonnull) imageTag completion: (nullable void (^)(NSError * _Nullable error, UIImage * _Nullable watermarkedImage)) completion;
- (void) setImageMetadata: (PGMetarImageTag *_Nonnull) imageTag mediaMetada:(PGMetarMedia *_Nonnull) metadata completion: (nullable void (^)(NSError * _Nullable error)) completion;
- (void) requestImageMetadataWithUUID: (NSString *_Nonnull) uuid completion: (nullable void (^)(NSError * _Nullable error, PGMetarMedia * _Nullable metarMedia)) completion;
- (void) getOfflineTags: (nullable void (^)(NSError * _Nullable error, NSArray * _Nullable tags)) completion;

// TODO: implement
- (void) requestImageMetadataWithFilter;

// TODO: implement when available, future spec
- (void) downloadImage;

@end
