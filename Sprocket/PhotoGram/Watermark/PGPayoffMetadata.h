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
#import "HPPRMedia.h"

extern NSString * const kPGPayoffMetadataURLKey;
extern NSString * const kPGPayoffTypeKey;
extern NSString * const kPGPayoffUUIDKey;
extern NSString * const kPGPayoffDataKey;
extern NSString * const kPGPayoffMetadataAssetIdentifierKey;

typedef enum {
    kPGPayoffNoType, // undefined
    kPGPayoffURL, // simply open URL
    kPGPayoffVideo, // play video
    kPGPayoffMetaPresentation, // show extended information based on metadata,
    kPGPayoffURLMetar, // METAR API rich content,
    kPGPayoffURLBatata, // OLD batata API tagged photos
} tPGPayoffMetadataType;


// mega-object representing possible payoff metadata
@interface PGPayoffMetadata : NSObject
@property (strong, nonatomic) NSString * uuid;
@property (assign, nonatomic) BOOL offline;
@property (assign, nonatomic) tPGPayoffMetadataType type;
@property (strong, nonatomic) NSDictionary* data;


+(instancetype) metaFromHPPRMedia: (HPPRMedia *) media;
+(instancetype)offlinePayoffFromDictionary:(NSDictionary *) data;
+(instancetype)onlineURLPayoff:(NSURL *)url;

-(NSDictionary *) toDictionary;

// helper methods to access meta
-(NSURL*) URL;
-(NSString*) assetIdentifier;

-(PHAsset*) fetchPHAsset;

@end
