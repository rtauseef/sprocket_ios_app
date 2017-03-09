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

#import <MP.h>
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

#import "PGBaseAnalyticsManager.h"
#import "PGExperimentManager.h"
#import "PGSecretKeeper.h"

@implementation PGBaseAnalyticsManager

    NSString * const kMetricsTypePhotoSourceKey = @"kMetricsTypePhotoSourceKey";
NSString * const kMetricsTypePhotoPositionKey = @"kMetricsTypePhotoPositionKey";
NSString * const kMetricsTypeLocationKey = @"kMetricsTypeLocationKey";
NSString * const kMetricsOfframpKey = @"off_ramp";
NSString * const kMetricsAppTypeKey = @"app_type";
NSString * const kMetricsAppTypeHP = @"HP";

NSUInteger const kPGExperimentPrintIconDimension = 1;
NSString * const kPGExperimentPrintIconVisible = @"icon visible";
NSString * const kPGExperimentPrintIconNotVisible = @"icon not visible";

NSUInteger const kEventDefaultValue = 0;

NSString * const kEventPrinterConnectCategory = @"PrinterConnect";
NSString * const kActionPrinterConnected      = @"Connected";
NSString * const kActionPrinterDisconnected   = @"Disconnected";

+ (PGBaseAnalyticsManager *)sharedManager
{
    static PGBaseAnalyticsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        [sharedManager setupSettings];
    });
    
    return sharedManager;
}

// The following is adapted from the technique used in MobilePrintSDK. See MPAnalyticsManager::metricsServerURL
- (NSString *)googleTrackingId
{
    NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    
    // The following is adapted from: http://stackoverflow.com/questions/26081543/how-to-tell-at-runtime-whether-an-ios-app-is-running-through-a-testflight-beta-i
    BOOL sandboxReceipt = [[[[NSBundle mainBundle] appStoreReceiptURL] lastPathComponent] isEqualToString:@"sandboxReceipt"];
    
    NSString *trackingId;
    if (!provisionPath && !sandboxReceipt && !TARGET_IPHONE_SIMULATOR) {
        trackingId = [[PGSecretKeeper sharedInstance] secretForEntry:SecretKeeperEntryGoogleAnalyticsTrakingId];
    } else {
        trackingId = [[PGSecretKeeper sharedInstance] secretForEntry:SecretKeeperEntryGoogleAnalyticsTrakingIdDev];
    }
    return trackingId;
}

- (void)setupSettings
{
    GAI *gai = [GAI sharedInstance];
    
    gai.trackUncaughtExceptions = YES;
    gai.logger.logLevel = kGAILogLevelNone;
    
#ifdef DEBUG
    gai.dispatchInterval = 10;
#else
    gai.dispatchInterval = 120;
#endif
    
    gai.defaultTracker = [gai trackerWithTrackingId:[self googleTrackingId]];
    
    [gai.defaultTracker set:kGAIUserId value:[[UIDevice currentDevice].identifierForVendor UUIDString]];
    
    [self setupExperiments];
}

- (void)setupExperiments
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    NSString *experimentValue = kPGExperimentPrintIconNotVisible;
    if ([PGExperimentManager sharedInstance].showPrintIcon) {
        experimentValue = kPGExperimentPrintIconVisible;
    }
    
    [tracker set:[GAIFields customDimensionForIndex:kPGExperimentPrintIconDimension] value:experimentValue];
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

/**
 trackEvent
 Category: The primary divisions of the types of Events you have on your site. Categories
 are at the root of Event tracking, and should function as a first way to sort Events in
 your reports. "Videos" and "Downloads" are good examples of categories, though you can
 be as specific or broad as your content requires.
 
 Action: A descriptor for a particular Event Category. You can use any string to define an
 Action, so you can be as specific as necessary. For example, you could define "Play" or
 "Pause" as Actions for a Video. You could also be more specific, and create an Action
 called "Video almost finished" to trigger when the play-back slider on a video reaches
 the 90% mark.
 
 Label: An optional descriptor that you can use to provide further granularity. You can
 specify any string for a label.
 
 Value: An optional numerical variable. You can use explicit values, like 30, or inferred
 values based on variables you define elsewhere, like downloadTime.
 */
- (void) trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build]];
}

- (void)trackScreenViewEvent:(NSString *)screenName
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)trackPrinterConnected:(BOOL)connected screenName:(NSString *)screenName
{
    NSString *action = connected ? kActionPrinterConnected : kActionPrinterDisconnected;
    
    [self trackEvent:kEventPrinterConnectCategory action:action label:screenName value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
}

- (void)fireTestException {
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:@"Exception Test" withFatal:@YES] build]];
}

@end
