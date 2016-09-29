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
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#define HP_PHOTO_PROVIDER_DOMAIN @"com.hp.photo-provider-pod"
#define ALBUM_DOES_NOT_EXISTS      -100

@class HPPRSelectPhotoProvider;

@interface HPPRAlbum : NSObject

@property (nonatomic, weak) HPPRSelectPhotoProvider *provider;
@property (nonatomic, strong) NSString *objectID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSUInteger photoCount;
@property (nonatomic, strong) UIImage *coverPhoto;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

+ (NSError *)albumDeletedError;

- (id)initWithAttributes:(NSDictionary *)attributes;
- (void)setAttributes:(NSDictionary *)attributes;

@end
