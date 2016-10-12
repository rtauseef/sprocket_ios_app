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

#import "PGBaseAnalyticsManager.h"
#import <MP.h>

@implementation PGBaseAnalyticsManager

    NSString * const kMetricsTypePhotoSourceKey = @"kMetricsTypePhotoSourceKey";
NSString * const kMetricsTypePhotoPositionKey = @"kMetricsTypePhotoPositionKey";
NSString * const kMetricsTypeLocationKey = @"kMetricsTypeLocationKey";
NSString * const kMetricsOfframpKey = @"off_ramp";
NSString * const kMetricsAppTypeKey = @"app_type";
NSString * const kMetricsAppTypeHP = @"HP";
    
+ (PGBaseAnalyticsManager *)sharedManager
{
    static PGBaseAnalyticsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (NSMutableDictionary *)getMetrics:(NSString *)offramp printItem:(MPPrintItem *)printItem exendedInfo:(NSDictionary *)extendedInfo
{
    MPPaper *paper = [[MPPaper alloc] initWithPaperSize:MPPaperSize2x3 paperType:MPPaperTypePhoto];
    NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionaryWithDictionary:[MP sharedInstance].lastOptionsUsed];
    [lastOptionsUsed setValue:paper.typeTitle forKey:kMPPaperTypeId];
    [lastOptionsUsed setValue:paper.sizeTitle forKey:kMPPaperSizeId];
    [lastOptionsUsed setValue:[NSNumber numberWithFloat:paper.width] forKey:kMPPaperWidthId];
    [lastOptionsUsed setValue:[NSNumber numberWithFloat:paper.height] forKey:kMPPaperHeightId];
    [lastOptionsUsed setValue:[NSNumber numberWithBool:NO] forKey:kMPBlackAndWhiteFilterId];
    [lastOptionsUsed setValue:[NSNumber numberWithInteger:1] forKey:kMPNumberOfCopies];
    [MP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];
    
    NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithObjectsAndKeys:offramp, kMetricsOfframpKey, kMetricsAppTypeHP, kMetricsAppTypeKey, nil];
    [metrics addEntriesFromDictionary:printItem.extra];
    [metrics addEntriesFromDictionary:[extendedInfo objectForKey:kMetricsTypeLocationKey]];
    [metrics addEntriesFromDictionary:[extendedInfo objectForKey:kMetricsTypePhotoSourceKey]];
    [metrics addEntriesFromDictionary:[extendedInfo objectForKey:kMetricsTypePhotoPositionKey]];
    [metrics setObject:offramp forKey:kMetricsOfframpKey];
    
    NSMutableDictionary *remaining = [NSMutableDictionary dictionaryWithDictionary:extendedInfo];
    [remaining removeObjectsForKeys:@[kMetricsOfframpKey, kMetricsTypeLocationKey, kMetricsTypePhotoSourceKey, kMetricsTypePhotoPositionKey]];
    [metrics addEntriesFromDictionary:remaining];
    
    return metrics;
}

- (void)postMetricsWithOfframp:(NSString *)offramp printItem:(MPPrintItem *)printItem exendedInfo:(NSDictionary *)extendedInfo
{
    NSMutableDictionary *metrics = [self getMetrics:offramp printItem:printItem exendedInfo:extendedInfo];
    [self postMetrics:offramp object:printItem metrics:metrics];
}

- (void)postMetrics:(NSString *)offramp object:(NSObject *)object metrics:(NSDictionary *)metrics
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPShareCompletedNotification object:object userInfo:metrics];
}
    
@end
