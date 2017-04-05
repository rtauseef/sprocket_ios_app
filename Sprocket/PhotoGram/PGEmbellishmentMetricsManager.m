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

#import "PGEmbellishmentMetricsManager.h"

@interface PGEmbellishmentMetricsManager()

@property (nonatomic, strong) NSMutableArray *metrics;

@end

@implementation PGEmbellishmentMetricsManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.metrics = [NSMutableArray array];
    }
    return self;
}

- (NSString *)embellishmentMetricsString
{
    NSString *embellishmentMetricsString = @"";
    
    for (PGEmbellishmentMetric *metric in self.metrics) {
        embellishmentMetricsString = [embellishmentMetricsString stringByAppendingString:metric.toEmbellishmentString];
    }
    
    return embellishmentMetricsString;
}

- (BOOL)hasEmbellishmentMetric:(PGEmbellishmentMetric *)metricWanted
{
    for (PGEmbellishmentMetric *metric in self.metrics) {
        if ([metricWanted isEqual:metric]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)addEmbellishmentMetric:(PGEmbellishmentMetric *)metric
{
    [self.metrics addObject:metric];
}

- (void)removeEmbellishmentMetric:(PGEmbellishmentMetric *)metric
{
    for (PGEmbellishmentMetric *metricStored in self.metrics) {
        if ([metric isEqual:metricStored]) {
            [self.metrics removeObject:metricStored];
            return;
        }
    }
}

- (void)clearEmbellishmentMetricForCategory:(PGEmbellishmentCategoryType)type
{
    NSMutableArray *objectsToRemove = [NSMutableArray array];
    for (PGEmbellishmentMetric *metricStored in self.metrics) {
        if (metricStored.category.type == type) {
            [objectsToRemove addObject:metricStored];
        }
    }
    
    [self.metrics removeObjectsInArray:objectsToRemove];
}


@end
