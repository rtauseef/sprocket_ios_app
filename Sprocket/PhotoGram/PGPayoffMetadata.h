//
//  PGPayoffMetadata.h
//  Sprocket
//
//  Created by Bruno Dal Bo on 4/17/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kPGPayoffMetadataURLKey;
extern NSString * const kPGPayoffTypeKey;
extern NSString * const kPGPayoffUUIDKey;
extern NSString * const kPGPayoffDataKey;


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

+(instancetype) offlineVideoPayoffWithAsset:(NSURL*) asset;
+(instancetype) offlinePayoffWithDictionary:(NSDictionary *) data;
+(instancetype) onlineURLPayoff:(NSURL *) url;

-(NSDictionary *) toDictionary;

// helper methods to access meta
-(NSURL*) URL;

@end
