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

extern NSString * const kMetricsOffRampPrintNoUISingle;
extern NSString * const kMetricsOffRampPrintNoUIMulti;

extern NSString * const kMetricsOrigin;
extern NSString * const kMetricsOriginSingle;
extern NSString * const kMetricsOriginMulti;
extern NSString * const kMetricsOriginCopies;
extern NSString * const kMetricsOriginTile;
extern NSString * const kMetricsOriginParty;

extern NSString * const kMetricsOffRampQueueAddSingle;
extern NSString * const kMetricsOffRampQueueAddMulti;
extern NSString * const kMetricsOffRampQueueAddCopies;
extern NSString * const kMetricsOffRampQueueAddTile;
extern NSString * const kMetricsOffRampQueueAddParty;

extern NSString * const kMetricsOffRampQueuePrintSingle;
extern NSString * const kMetricsOffRampQueuePrintMulti;
extern NSString * const kMetricsOffRampQueuePrintCopies;
extern NSString * const kMetricsOffRampQueuePrintTile;
extern NSString * const kMetricsOffRampQueuePrintParty;

extern NSString * const kMetricsOffRampQueueDeleteCopies;
extern NSString * const kMetricsOffRampQueueDeleteMulti;
extern NSString * const kMetricsOffRampQueueDeleteTile;
extern NSString * const kMetricsOffRampQueueDeleteParty;

extern NSString * const kEventPrintQueueMenuCategory;
extern NSString * const kEventPrintQueuePreviewCategory;
extern NSString * const kEventPrintQueueDeleteAllAction;
extern NSString * const kEventPrintQueuePrintAction;

extern NSString * const kEventAuthRequestOkAction;
extern NSString * const kEventAuthRequestDeniedAction;
extern NSString * const kEventAuthRequestPhotosLabel;
extern NSString * const kEventAuthRequestCameraLabel;

extern NSString * const kEventSaveProjectDismiss;
extern NSString * const kEventSaveProjectPreview;

extern NSString * const kEventDismissEditOkAction;
extern NSString * const kEventDismissEditSaveAction;
extern NSString * const kEventDismissEditCancelAction;
extern NSString * const kEventDismissEditCameraLabel;
extern NSString * const kEventDismissEditCloseLabel;

extern NSString * const kEventSocialSignInCancelAction;
extern NSString * const kEventSocialSignInSuccessAction;

extern NSString * const kEventCameraDirectionBackLabel;
extern NSString * const kEventCameraDirectionSelfieLabel;

extern NSString * const kEventCameraTimerNoneLabel;
extern NSString * const kEventCameraTimer3sLabel;
extern NSString * const kEventCameraTimer10sLabel;

extern NSString * const kEventCameraFlashOnLabel;
extern NSString * const kEventCameraFlashOffLabel;

extern NSString * const kEventPrintButtonLabel;
extern NSString * const kEventPrintShareLabel;

extern NSString * const kEventPrintJobPrintSingleAction;
extern NSString * const kEventPrintJobPrintMultiAction;
extern NSString * const kEventPrintJobPrintCopiesAction;
extern NSString * const kEventPrintJobPrintTileAction;
extern NSString * const kEventPrintJobPrintPartyAction;

extern NSString * const kEventPrintQueueAddMultiAction;
extern NSString * const kEventPrintQueueAddSingleAction;
extern NSString * const kEventPrintQueueAddCopiesAction;
extern NSString * const kEventPrintQueueAddTileAction;
extern NSString * const kEventPrintQueueAddPartyAction;

extern NSString * const kEventPrintQueuePrintMultiAction;
extern NSString * const kEventPrintQueuePrintSingleAction;
extern NSString * const kEventPrintQueuePrintCopiesAction;
extern NSString * const kEventPrintQueuePrintTileAction;
extern NSString * const kEventPrintQueuePrintPartyAction;

extern NSString * const kEventPrintQueueDeleteMultiAction;
extern NSString * const kEventPrintQueueDeleteCopiesAction;
extern NSString * const kEventPrintQueueDeleteTileAction;
extern NSString * const kEventPrintQueueDeletePartyAction;

extern NSString * const kEventMultiSelectCancel;
extern NSString * const kEventMultiSelectEnable;
extern NSString * const kEventMultiSelectPreview;

extern NSString * const kEventCustomStickerCategory;
extern NSString * const kEventCustomStickerActionYes;
extern NSString * const kEventCustomStickerActionNo;

extern NSString * const kPhotoCollectionViewModeGrid;
extern NSString * const kPhotoCollectionViewModeList;

+ (PGAnalyticsManager *)sharedManager;

- (void)trackShareActivity:(NSString *)activityName withResult:(NSString *)result;
- (void)trackShareActivity:(NSString *)activityName withResult:(NSString *)result andNumberOfPhotos:(NSUInteger)numberOfPhotos;
- (void)trackAuthRequestActivity:(NSString *)action device:(NSString *)device;
- (void)trackDismissEditActivity:(NSString *)action source:(NSString *)source;
- (void)trackSaveProjectActivity:(NSString *)source;
- (void)trackMultiSaveProjectActivity:(NSString *)source numberOfPhotos:(NSUInteger)numberOfPhotos;
- (void)trackCameraDirectionActivity:(NSString *)direction;
- (void)trackCameraTimerActivity:(NSString *)timer;
- (void)trackCameraFlashActivity:(NSString *)flash;
- (void)trackCameraAutoSavePreferenceActivity:(NSString *)preference;
- (void)trackSocialSignInActivity:(NSString *)action provider:(NSString *)provider;
- (void)trackSelectPhoto:(NSString *)source;
- (void)trackPhotoCollectionViewMode:(NSString *)mode;
- (void)trackPrintRequest:(NSString *)source;
- (void)trackCameraGallerySelect;
- (void)trackOpenAppSettings;
- (void)trackOpenPrivacy;
- (void)trackOpenBuyPaper;
- (void)trackCustomStickerConfirm:(BOOL)confirmed;

- (void)trackPrintQueueAction:(NSString *)action queueId:(NSInteger)queueId;
- (void)trackPrintQueueAction:(NSString *)action queueId:(NSInteger)queueId queueSize:(NSUInteger)queueSize;
- (void)trackPrintQueueModalAction:(NSString *)category queueId:(NSInteger)queueId numItemsDeleted:(NSUInteger)numItemsDeleted;
- (void)trackPrintJobAction:(NSString *)action printerId:(NSString *)printerId;

- (void)switchSource:(NSString *)socialNetwork userName:(NSString *)userName userId:(NSString *)userId;
- (NSDictionary *)photoSourceMetrics;
- (NSDictionary *)photoPositionMetricsWithOffset:(CGPoint)offset zoom:(CGFloat)zoom angle:(CGFloat)angle;

+ (NSString *)wifiName;

- (void)trackMultiSelect:(NSString *)action selectedPhotos:(NSNumber * _Nullable)selectedPhotos;
- (void)trackHelpLinksActivity:(NSString * _Nonnull)action;

@end
