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

@interface PGCloudAssetImage : NSObject <NSSecureCoding>

@property (nonatomic, assign) NSInteger assetId;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger position;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *assetURL;
@property (nonatomic, copy) NSString *thumbnailURL;

+ (instancetype)assetWithData:(NSDictionary *)data;

@end
