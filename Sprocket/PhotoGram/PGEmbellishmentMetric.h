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
#import "PGEmbellishmentCategory.h"

static const NSString *kPGEmbellishmentMetricCategory = @"category";
static const NSString *kPGEmbellishmentMetricName = @"name";

@interface PGEmbellishmentMetric : NSObject

@property (nonatomic, strong) PGEmbellishmentCategory *category;
@property (nonatomic, strong) NSString *name;

- (instancetype)initWithName:(NSString *)name andCategoryType:(PGEmbellishmentCategoryType)categoryType;

- (NSDictionary *)toDictionary;
- (NSString *)toEmbellishmentString;

@end
