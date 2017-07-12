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

@interface PGMetarVideo : NSObject

@property (strong, nonatomic) NSNumber* length;
@property (strong, nonatomic) NSString* encoding;
@property (strong, nonatomic) NSNumber* bitrate;
@property (strong, nonatomic) NSString* artist;

- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) getDict;

@end
