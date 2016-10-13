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

@interface PGAnalyticsManager : PGBaseAnalyticsManager

@property (strong) NSString *imageURL;
@property (strong) NSString *templateName;
@property (strong) NSString *templatePosition;
@property (strong) NSString *templateText;
@property (assign) BOOL templateTextEdited;
@property (strong) NSString *photoSource;
@property (strong) NSString *paperSize;
@property (assign) BOOL trackPhotoPosition;
@property (assign) BOOL photoPanEdited;
@property (assign) BOOL photoZoomEdited;
@property (assign) BOOL photoRotationEdited;

extern NSString * const kEventResultSuccess;
extern NSString * const kEventResultCancel;

extern NSString * const kMPMetricsEmbellishmentKey;

extern NSString * const kEventAuthRequestOkAction;
extern NSString * const kEventAuthRequestDeniedAction;
extern NSString * const kEventAuthRequestPhotosLabel;
extern NSString * const kEventAuthRequestCameraLabel;

extern NSString * const kEventDismissEditOkAction;
extern NSString * const kEventDismissEditSaveAction;
extern NSString * const kEventDismissEditCancelAction;
extern NSString * const kEventDismissEditCameraLabel;
extern NSString * const kEventDismissEditCloseLabel;

extern NSString * const kEventSocialSignInCancelAction;
extern NSString * const kEventSocialSignInSuccessAction;

extern NSString * const kEventCameraDirectionBackLabel;
extern NSString * const kEventCameraDirectionSelfieLabel;

extern NSString * const kEventPrintButtonLabel;
extern NSString * const kEventPrintShareLabel;

+ (PGAnalyticsManager *)sharedManager;

- (void)trackScreenViewEvent:(NSString *)screenName;
- (void)trackShareActivity:(NSString *)activityName withResult:(NSString *)result;
- (void)trackAuthRequestActivity:(NSString *)action device:(NSString *)device;
- (void)trackDismissEditActivity:(NSString *)action source:(NSString *)source;
- (void)trackCameraDirectionActivity:(NSString *)direction;
- (void)trackSocialSignInActivity:(NSString *)action provider:(NSString *)provider;
- (void)trackSelectPhoto:(NSString *)source;
- (void)trackPrintRequest:(NSString *)source;
- (void)switchSource:(NSString *)socialNetwork userName:(NSString *)userName userId:(NSString *)userId;
- (NSDictionary *)photoSourceMetrics;
- (NSDictionary *)photoPositionMetricsWithOffset:(CGPoint)offset zoom:(CGFloat)zoom angle:(CGFloat)angle;

+ (NSString *)wifiName;

@end
