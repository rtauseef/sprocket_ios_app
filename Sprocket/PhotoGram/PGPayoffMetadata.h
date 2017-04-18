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
#import <Photos/Photos.h>

extern NSString * const kPGPayoffMetadataURLKey;
extern NSString * const kPGPayoffTypeKey;
extern NSString * const kPGPayoffUUIDKey;
extern NSString * const kPGPayoffDataKey;
extern NSString * const kPGPayoffMetadataAssetIdentifierKey;

typedef enum {
    kPGPayoffNoType, // undefined
    kPGPayoffURL, // simply open URL
    kPGPayoffVideo, // play video
    kPGPayoffMetaPresentation // show extended information based on metadata
} tPGPayoffMetadataType;


// mega-object representing possible payoff metadata
@interface PGPayoffMetadata : NSObject
@property NSString * uuid;
@property BOOL offline;
@property tPGPayoffMetadataType type;
@property NSDictionary* data;


+(instancetype) offlineVideoPayoffWithAsset:(PHAsset*) asset;
+(instancetype) offlinePayoffFromDictionary:(NSDictionary *) data;
+(instancetype) onlineURLPayoff:(NSURL *) url;

-(NSDictionary *) toDictionary;

// helper methods to access meta
-(NSURL*) URL;
-(NSString*) assetIdentifier;

-(PHAsset*) fetchPHAsset;

@end
