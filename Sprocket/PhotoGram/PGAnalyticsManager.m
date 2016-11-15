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

#import <Crashlytics/Crashlytics.h>
#import "PGAnalyticsManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <MP.h>
#import <MPPrintManager.h>
#import <HPPR.h>

#define CRASHLYTICS_KEY @"fed1fe4ea8a4c5778ff0754bc1851f8f8ef7f5ed"

NSString * const kNoPhotoSelected = @"No Photo";
NSString * const kNoNetwork = @"NO-WIFI";

NSString * const kYesValue = @"Yes";
NSString * const kNoValue = @"No";

@interface PGAnalyticsManager ()

@property (strong) NSString *userName;
@property (strong) NSString *userId;
@property (strong) NSString *socialNetwork;

@end

@implementation PGAnalyticsManager

NSString * const kMetricsCard = @"card";
NSString * const kMetricsPhotoSource = @"photo_source";
NSString * const kMetricsTemplateName = @"template_name";
NSString * const kMetricsTemplatePosition = @"template_position";
NSString * const kMetricsTemplateText = @"template_text";
NSString * const kMetricsTemplatedTextEdited = @"template_text_edited";
NSString * const kMetricsUserID = @"user_id";
NSString * const kMetricsUserName = @"user_name";
NSString * const kMetricsPhotoPanEdited = @"photo_pan_edited";
NSString * const kMetricsPhotoZoomEdited = @"photo_zoom_edited";
NSString * const kMetricsPhotoAngleEdited = @"photo_angle_edited";
NSString * const kMetricsPhotoAngle = @"photo_angle";
NSString * const kNonPrintingActivity = @"No Print";
NSString * const kCrashlyticsOfframpKey = @"Offramp";
NSString * const kCrashlyticsWiFiShareKey = @"WiFi (share/print)";

NSString * const kEventSelectTemplateCategory = @"Template";
NSString * const kEventSelectTemplateAction = @"Select";

NSString * const kEventShareActivityCategory = @"Share";
NSString * const kEventResultSuccess = @"Success";
NSString * const kEventResultCancel = @"Cancel";

NSString * const kEventAuthRequestCategory      = @"AuthRequest";
NSString * const kEventAuthRequestOkAction      = @"OK";
NSString * const kEventAuthRequestDeniedAction  = @"Denied";
NSString * const kEventAuthRequestPhotosLabel   = @"Photos";
NSString * const kEventAuthRequestCameraLabel   = @"Camera";

NSString * const kEventSaveProjectCategory      = @"SaveProject";
NSString * const kEventSaveProjectSaveAction    = @"Save";
NSString * const kEventSaveProjectDismiss       = @"SaveFromDismissEdits";
NSString * const kEventSaveProjectPreview       = @"SaveFromPreview";

NSString * const kEventDismissEditCategory      = @"DismissEdits";
NSString * const kEventDismissEditOkAction      = @"OK";
NSString * const kEventDismissEditSaveAction    = @"Save";
NSString * const kEventDismissEditCancelAction  = @"Cancel";
NSString * const kEventDismissEditCameraLabel   = @"Camera";
NSString * const kEventDismissEditCloseLabel    = @"X";

NSString * const kEventCameraDirectionCategory     = @"CameraDirection";
NSString * const kEventCameraDirectionSwitchAction = @"Switch";
NSString * const kEventCameraDirectionBackLabel    = @"Back";
NSString * const kEventCameraDirectionSelfieLabel  = @"Selfie";

NSString * const kEventSocialSignInCategory      = @"SocialSignIn";
NSString * const kEventSocialSignInCancelAction  = @"Cancel";
NSString * const kEventSocialSignInSuccessAction = @"SignIn";

NSString * const kEventPhotoCategory     = @"Photo";
NSString * const kEventPhotoSelectAction = @"Select";

NSString * const kEventPrintJobCategory        = @"PrintJob";
NSString * const kEventPrintJobErrorCategory   = @"PrintJobError";
NSString * const kEventPrintJobStartedAction   = @"Started";
NSString * const kEventPrintJobCompletedAction = @"Completed";

NSString * const kEventPrintCategory    = @"Print";
NSString * const kEventPrintAction      = @"Print";
NSString * const kEventPrintButtonLabel = @"PrintButton";
NSString * const kEventPrintShareLabel  = @"ShareButton";

NSString * const kEventPrinterNotConnectedCategory = @"PrinterNotConnected";
NSString * const kEventPrinterNotConnectedAction = @"OK";

NSString * const kMPMetricsEmbellishmentKey = @"sprocket_embellishments";

@synthesize templateName = _templateName;

+ (PGAnalyticsManager *)sharedManager
{
    static PGAnalyticsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        [sharedManager setupSettings];
    });
    
    return sharedManager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private methods

- (void)setupSettings
{
    self.photoSource = kNoPhotoSelected;
    self.imageURL = kNoPhotoSelected;
    self.userName = kNoPhotoSelected;
    self.userId = kNoPhotoSelected;
    
    [[MP sharedInstance] obfuscateMetric:kMetricsUserID];
    [[MP sharedInstance] obfuscateMetric:kMetricsUserName];
    
    [self setupCrashlytics];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintQueueNotification:) name:kMPPrintQueueNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTrackableScreenNotification:) name:kMPTrackableScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintJobStartedNotification:) name:kMPBTPrintJobStartedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintJobCompletedNotification:) name:kMPBTPrintJobCompletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrinterNotConnectedNotification:) name:kMPBTPrinterNotConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTrackableScreenNotificationHPPR:) name:HPPR_TRACKABLE_SCREEN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginCancelNotificationHPPR:) name:HPPR_PROVIDER_LOGIN_CANCEL_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginSuccessNotificationHPPR:) name:HPPR_PROVIDER_LOGIN_SUCCESS_NOTIFICATION object:nil];
}

#pragma mark - Events

- (void)handleTrackableScreenNotification:(NSNotification *)notification
{
    [self trackScreenViewEvent:[notification.userInfo objectForKey:kMPTrackableScreenNameKey]];
}

- (void)handleTrackableScreenNotificationHPPR:(NSNotification *)notification
{
    [self trackScreenViewEvent:[notification.userInfo objectForKey:kHPPRTrackableScreenNameKey]];
}

- (void)handleLoginCancelNotificationHPPR:(NSNotification *)notification
{
    [self trackSocialSignInActivity:kEventSocialSignInCancelAction provider:[notification.userInfo objectForKey:kHPPRProviderName]];
}

- (void)handleLoginSuccessNotificationHPPR:(NSNotification *)notification
{
    [self trackSocialSignInActivity:kEventSocialSignInSuccessAction provider:[notification.userInfo objectForKey:kHPPRProviderName]];
}

- (void)handlePrintJobStartedNotification:(NSNotification *)notification
{
    [self trackEvent:kEventPrintJobCategory action:kEventPrintJobStartedAction label:[notification.userInfo objectForKey:kMPBTPrintJobPrinterIdKey] value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
}

- (void)handlePrintJobCompletedNotification:(NSNotification *)notification
{
    NSString *error = [notification.userInfo objectForKey:kMPBTPrintJobErrorKey];

    if (nil == error) {
        [self trackEvent:kEventPrintJobCategory action:kEventPrintJobCompletedAction label:[notification.userInfo objectForKey:kMPBTPrintJobPrinterIdKey] value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
    } else {
        [self trackEvent:kEventPrintJobErrorCategory action:error label:[notification.userInfo objectForKey:kMPBTPrintJobPrinterIdKey] value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
        [self trackEvent:kEventPrintJobCategory action:@"Error" label:[notification.userInfo objectForKey:kMPBTPrintJobPrinterIdKey] value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
    }
}

- (void)handlePrinterNotConnectedNotification:(NSNotification *)notification
{
    [self trackEvent:kEventPrinterNotConnectedCategory action:kEventPrinterNotConnectedAction label:[notification.userInfo objectForKey:kMPBTPrinterNotConnectedSourceKey] value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
}

- (void)trackShareActivity:(NSString *)activityName withResult:(NSString *)result
{
    [self trackEvent:kEventShareActivityCategory action:activityName label:result value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
}

- (void)trackAuthRequestActivity:(NSString *)action device:(NSString *)device
{
    [self trackEvent:kEventAuthRequestCategory action:action label:device value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
}

- (void)trackDismissEditActivity:(NSString *)action source:(NSString *)source
{
    [self trackEvent:kEventDismissEditCategory action:action label:source value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
    
    if ([kEventDismissEditSaveAction isEqualToString:action]) {
        [self trackSaveProjectActivity:kEventSaveProjectDismiss];
    }
}

- (void)trackSaveProjectActivity:(NSString *)source
{
    [self trackEvent:kEventSaveProjectCategory action:kEventSaveProjectSaveAction label:source value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
}

- (void)trackCameraDirectionActivity:(NSString *)direction
{
    [self trackEvent:kEventCameraDirectionCategory action:kEventCameraDirectionSwitchAction label:direction value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
}

- (void)trackSocialSignInActivity:(NSString *)action provider:(NSString *)provider
{
    [self trackEvent:kEventSocialSignInCategory action:action label:provider value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
}

- (void)trackSelectPhoto:(NSString *)source
{
    [self trackEvent:kEventPhotoCategory action:kEventPhotoSelectAction label:source value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
}

- (void)trackPrintRequest:(NSString *)source
{
    [self trackEvent:kEventPrintCategory action:kEventPrintAction label:source value:[NSNumber numberWithUnsignedInteger:kEventDefaultValue]];
}

- (void) trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    [super trackEvent:category action:action label:label value:value];
    PGLogInfo(@"Google Anayltics Event - Category:\"%@\", Action:\"%@\", Label:\"%@\", Value:\"%@\"", category, action, label, value);
}

- (void)trackScreenViewEvent:(NSString *)screenName
{
    [super trackScreenViewEvent:screenName];
    PGLogInfo(@"Google Anayltics Screen View:  %@", screenName);
}

- (void)fireTestException
{
    [super fireTestException];
    
    [[Crashlytics sharedInstance] throwException];
}

#pragma mark - Photo metrics 

- (NSDictionary *)photoSourceMetrics
{
    return @{
             kMetricsCard: @"This column has been deprecated. Use the 'template_name' column instead.",
             kMetricsPhotoSource: [self nonNullString:self.photoSource],
             kMetricsTemplateName: [self nonNullString:self.templateName],
             kMetricsTemplatePosition: [self nonNullString: self.templatePosition],
             kMetricsTemplateText: [self nonNullString:self.templateText],
             kMetricsTemplatedTextEdited: self.templateTextEdited ? kYesValue : kNoValue,
             kMetricsUserID: [self nonNullString:self.userId],
             kMetricsUserName: [self nonNullString:self.userName],
             };
}


- (NSDictionary *)photoPositionMetricsWithOffset:(CGPoint)offset zoom:(CGFloat)zoom angle:(CGFloat)angle
{
    return @{
             kMetricsPhotoPanEdited: self.photoPanEdited ? kYesValue : kNoValue,
             kMetricsPhotoZoomEdited: self.photoZoomEdited ? kYesValue : kNoValue,
             kMetricsPhotoAngleEdited: self.photoRotationEdited ? kYesValue : kNoValue,
             kMetricsPhotoAngle: [NSString stringWithFormat:@"%.1f", angle]
            };
}

#pragma mark - Helpers

- (NSString *)nonNullString:(NSString *)value
{
    return nil == value ? @"" : value;
}

- (void)switchSource:(NSString *)socialNetwork userName:(NSString *)userName userId:(NSString *)userId
{
    self.socialNetwork = socialNetwork;
    self.userName = userName;
    self.userId = userId;
    
    [[Crashlytics sharedInstance] setObjectValue:socialNetwork forKey:@"Photo Source"];
    [[Crashlytics sharedInstance] setObjectValue:userId forKey:@"User ID"];
    [[Crashlytics sharedInstance] setObjectValue:userName forKey:@"User Name"];
}

#pragma mark - WiFi SSID

// The following code is adapted from http://stackoverflow.com/questions/4712535/how-do-i-use-captivenetwork-to-get-the-current-wifi-hotspot-name

+ (NSString *)wifiName {
    NSString *wifiName = kNoNetwork;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            wifiName = info[@"SSID"];
        }
    }
    return wifiName;
}

#pragma mark - Print handling
    
- (void)postMetricsWithOfframp:(NSString *)offramp objects:(NSDictionary *)objects exendedInfo:(NSDictionary *)extendedInfo
{
    MPPrintItem *printItem = [objects objectForKey:kMPPrintQueuePrintItemKey];
    MPPrintLaterJob *job = [objects objectForKey:kMPPrintQueueJobKey];
    NSMutableDictionary *metrics = [self getMetrics:offramp printItem:printItem exendedInfo:extendedInfo];
   
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:job forKey:kMPPrintQueueJobKey];
    [dictionary setObject:printItem forKey:kMPPrintQueuePrintItemKey];

    [self postMetrics:offramp object:dictionary metrics:metrics];
}

- (void)postMetrics:(NSString *)offramp object:(NSObject *)object metrics:(NSDictionary *)metrics
{
    [super postMetrics:offramp object:object metrics:metrics];
    
    [[Crashlytics sharedInstance] setObjectValue:offramp forKey:kCrashlyticsOfframpKey];
    [[Crashlytics sharedInstance] setObjectValue:[PGAnalyticsManager wifiName] forKey:kCrashlyticsWiFiShareKey];
    if ([MPPrintManager printingOfframp:offramp]) {
        [self setPrintCrashlytics];
    } else {
        [self clearPrintCrashlytics];
    }
}

- (void)handlePrintQueueNotification:(NSNotification *)notification
{
    NSString *action = [notification.object objectForKey:kMPPrintQueueActionKey];
    MPPrintLaterJob *job = [notification.object objectForKey:kMPPrintQueueJobKey];
    MPPrintItem *printItem = [notification.object objectForKey:kMPPrintQueuePrintItemKey];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:job forKey:kMPPrintQueueJobKey];
    [dictionary setObject:printItem forKey:kMPPrintQueuePrintItemKey];
 
    [self postMetricsWithOfframp:action objects:dictionary exendedInfo:job.extra];
}

#pragma mark - Crashlytics

- (void)setTemplateName:(NSString *)templateName
{
    @synchronized(self) {
        _templateName = templateName;
        [[Crashlytics sharedInstance] setObjectValue:templateName forKey:@"Template Name"];
    }
}

- (NSString *)templateName
{
    @synchronized(self) {
        return _templateName;
    }
}

- (void)setupCrashlytics
{
    [Crashlytics startWithAPIKey:CRASHLYTICS_KEY];
    [[Crashlytics sharedInstance] setObjectValue:[PGAnalyticsManager wifiName] forKey:@"WiFi (app start)"];
    NSArray *keys = @[
                      @"WiFi (share/print)",
                      @"Offramp",
                      @"Paper Size",
                      @"Paper Type",
                      @"Black and White",
                      @"Printer ID",
                      @"Printer Name",
                      @"Printer Location",
                      @"Printer Model",
                      @"Photo Source",
                      @"Photo URL",
                      @"User ID",
                      @"User Name",
                      @"Text",
                      @"Offset",
                      @"Scale",
                      @"Rotation",
                      @"Screen Name",
                      @"Template Name"
                      ];

    for (NSString *key in keys) {
        [[Crashlytics sharedInstance] setObjectValue:@"N/A" forKey:key];
    }
}

- (void)clearPrintCrashlytics
{
    [[Crashlytics sharedInstance] setObjectValue:kNonPrintingActivity forKey:@"Paper Size"];
    [[Crashlytics sharedInstance] setObjectValue:kNonPrintingActivity forKey:@"Paper Type"];
    [[Crashlytics sharedInstance] setObjectValue:kNonPrintingActivity forKey:@"Number of Copies"];
    [[Crashlytics sharedInstance] setObjectValue:kNonPrintingActivity forKey:@"Black and White"];
    [[Crashlytics sharedInstance] setObjectValue:kNonPrintingActivity forKey:@"Printer ID"];
    [[Crashlytics sharedInstance] setObjectValue:kNonPrintingActivity forKey:@"Printer Name"];
    [[Crashlytics sharedInstance] setObjectValue:kNonPrintingActivity forKey:@"Printer Location"];
    [[Crashlytics sharedInstance] setObjectValue:kNonPrintingActivity forKey:@"Printer Model"];
}

- (void)setPrintCrashlytics
{
    NSDictionary *options = [MP sharedInstance].lastOptionsUsed;
    [[Crashlytics sharedInstance] setObjectValue:[options objectForKey:kMPPaperSizeId] forKey:@"Paper Size"];
    [[Crashlytics sharedInstance] setObjectValue:[options objectForKey:kMPPaperTypeId] forKey:@"Paper Type"];
    [[Crashlytics sharedInstance] setObjectValue:[options objectForKey:kMPNumberOfCopies] forKey:@"Number of Copies"];
    [[Crashlytics sharedInstance] setObjectValue:[options objectForKey:kMPBlackAndWhiteFilterId] forKey:@"Black and White"];
    [[Crashlytics sharedInstance] setObjectValue:[options objectForKey:kMPPrinterId] forKey:@"Printer ID"];
    [[Crashlytics sharedInstance] setObjectValue:[options objectForKey:kMPPrinterDisplayName] forKey:@"Printer Name"];
    [[Crashlytics sharedInstance] setObjectValue:[options objectForKey:kMPPrinterDisplayLocation] forKey:@"Printer Location"];
    [[Crashlytics sharedInstance] setObjectValue:[options objectForKey:kMPPrinterMakeAndModel] forKey:@"Printer Model"];
}

@end
