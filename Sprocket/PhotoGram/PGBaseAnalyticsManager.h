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
#import <MPPrintItem.h>

@interface PGBaseAnalyticsManager : NSObject

extern NSString * const kMetricsOfframpKey;
extern NSString * const kMetricsAppTypeKey;
extern NSString * const kMetricsAppTypeHP;
    
extern NSString * const kMetricsTypePhotoSourceKey;
extern NSString * const kMetricsTypePhotoSourceKey;
extern NSString * const kMetricsTypePhotoPositionKey;
extern NSString * const kMetricsTypeLocationKey;
extern NSUInteger const kEventDefaultValue;

+ (PGBaseAnalyticsManager *)sharedManager;

- (void)setupSettings;

- (void)postMetricsWithOfframp:(NSString *)offramp printItem:(MPPrintItem *)printItem exendedInfo:(NSDictionary *)extendedInfo;
    
- (void)postMetrics:(NSString *)offramp object:(NSObject *)object metrics:(NSDictionary *)metrics;

- (NSMutableDictionary *)getMetrics:(NSString *)offramp printItem:(MPPrintItem *)printItem exendedInfo:(NSDictionary *)extendedInfo;


- (void)trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
- (void)trackScreenViewEvent:(NSString *)screenName;
- (void)trackPrinterConnected:(BOOL)connected screenName:(NSString *)screenName;

- (void)fireTestException;

@end
