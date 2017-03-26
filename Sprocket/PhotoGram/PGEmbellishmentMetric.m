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

#import "PGEmbellishmentMetric.h"

@implementation PGEmbellishmentMetric

- (instancetype)initWithName:(NSString *)name andCategoryType:(PGEmbellishmentCategoryType)categoryType
{
    self = [super init];
    if (self) {
        _name = name;
        _category = [[PGEmbellishmentCategory alloc] initWithType:categoryType];
    }
    return self;
}

- (BOOL)isEqualToMetric:(PGEmbellishmentMetric *)metric
{
    if (!metric) {
        return NO;
    }
    
    BOOL haveEqualNames = [metric.name isEqualToString:self.name];
    BOOL haveEqualCategories = metric.category.type == self.category.type;

    return haveEqualNames && haveEqualCategories;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[PGEmbellishmentMetric class]]) {
        return NO;
    }
    
    return [self isEqualToMetric:(PGEmbellishmentMetric *)object];
}

- (NSDictionary *)toDictionary
{
    return @{
             kPGEmbellishmentMetricCategory : self.category.name,
             kPGEmbellishmentMetricName : self.name
             };
}

- (NSString *)toEmbellishmentString
{
    return [NSString stringWithFormat:@"%@:%@, %@:%@;", kPGEmbellishmentMetricName, self.name, kPGEmbellishmentMetricCategory, self.category.name];
}

@end
