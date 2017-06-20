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

@interface PGMetarImage : NSObject

@property (strong, nonatomic) NSNumber* aperture;
@property (strong, nonatomic) NSNumber* exposure;
@property (strong, nonatomic) NSNumber* usedFlash;
@property (strong, nonatomic) NSNumber* focalLength;
@property (strong, nonatomic) NSString* iso;
@property (strong, nonatomic) NSString* make;
@property (strong, nonatomic) NSString* model;

- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) getDict;

@end
