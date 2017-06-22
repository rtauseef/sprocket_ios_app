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
#import <CoreLocation/CoreLocation.h>
#import "PGMetarLocation.h"

@interface PGMetarIcon : NSObject

@property (strong, nonatomic) NSString* thumb;
@property (strong, nonatomic) NSString* original;

- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end

@interface PGMetarBlock: NSObject

@property (strong, nonatomic) NSNumber* index;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* text;

- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end

@interface PGMetarPage : NSObject

@property (strong, nonatomic) NSNumber* index;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* shortText;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) PGMetarLocation* location;
@property (strong, nonatomic) PGMetarIcon* icon;
@property (strong, nonatomic) NSString* from;
@property (strong, nonatomic) NSArray <PGMetarBlock *>* blocks;
@property (strong, nonatomic) NSArray <PGMetarIcon *>* images;
@property (strong, nonatomic) NSArray <NSString *>* externalLinks;

- (instancetype)initWithDictionary: (NSDictionary *) dict;

@end
