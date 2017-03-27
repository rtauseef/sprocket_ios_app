//
//  LRDetection.h
//  LinkReaderSDK
//
//  Created by LivePaper on 7/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRPayoff.h"

#define LR_PAYOFF_RESOLVER_ERROR_DOMAIN @"LRPayoffResolverErrorDomain"
#define LR_PAYOFF_ERROR_DOMAIN @"LRPayoffErrorDomain"

/**
 These are the errors which can occur when LinkReaderSDK is trying to get the experience related with QRCode or Watermark read.
 
 @since 2.0.0
 */
typedef NS_ENUM(NSInteger, LRPayoffResolverErrorCode) {
    LRPayoffResolverErrorCode_ServerError = 0,
    LRPayoffResolverErrorCode_PayloadNotFound,
    LRPayoffResolverErrorCode_PayloadOutOfRange,
    LRPayoffResolverErrorCode_BadResolveRequest,
    LRPayoffResolverErrorCode_ConnectionError,
    LRPayoffResolverErrorCode_RequestCancelled,
    LRPayoffResolverErrorCode_NetworkConnectionLost,
    LRPayoffResolverErrorCode_NetworkRequestTimedOut,
    LRPayoffResolverErrorCode_NotAuthorized
};

/**
 These are the errors which can occur when LinkReaderSDK is trying to parse the experience related with QRCode or Watermark read.
 
 @since 2.0.0
 */
typedef NS_ENUM(NSInteger, LRPayoffErrorCode) {
    LRPayoffErrorCode_PayoffNotPresentInData,
    LRPayoffErrorCode_InvalidPayoffData,
    LRPayoffErrorCode_MissingOrUnknownPayoffType,
    LRPayoffErrorCode_InvalidPayoffFormat
};


/**
 These are the type of mark LR can read.
 
 @since 1.2.0
 */
typedef NS_ENUM(NSInteger, LRTriggerType){
    
    LRTriggerTypeNone = -1,
    /**
     Payload read from watermark.
     
     @since 1.2.0
     */
    LRWatermark = 0,
    
    /**
     Payload read from QRCode.
     
     @since 1.0
     */
    LRQRCode = 1,
};


/**
 LRDetectionDelegate is responsible to send events related to mark detection and payoff resolving. 
 
 @since 2.0.0
 */
@protocol LRDetectionDelegate <NSObject>

/**
 When a payload has been detected and LinkReaderSDK can obtain the payoff linked to it, the delegate will be provided with the processed payoff or the raw data.
 
 @param payoff    An instance of LRPayoff.
 
 @since 2.0.0
 */
- (void)didFindPayoff:(id<LRPayoff> )payoff;

/**
 When a payload has been detected but an error has ocurred while trying to obtain the payoff linked to it, the delegate will be provided with the error.
 
 @param error     an error produced while attempting to obtain the payoff.
 
 @since 2.0.0
 */
- (void)errorOnPayoffResolving:(NSError *)error;

/**
 When a payload has been detected, LinkReader obtained a payoff linked to it and an error has ocurred when parsing it, the delegate will be provided with the error.
 
 @param error     an error produced while attempting to parse the payoff.
 
 @since 2.0.0
 */
- (void)errorOnPayoffParsing:(NSError *)error;


@optional

/**
 When a QRcode or Watermark has been detected, the delegate will be provided with the type of payload read.
 
 
 @param payloadType    type of mark read.
 
 @since 2.0.0
 */
- (void)didFindTrigger:(LRTriggerType)triggerType;

@end

#pragma mark -

/**
 The primary purpose of LRDetection is to allow the developer user to have finer-grained control over interaction with the LinkReaderSDK. If you wish to use a simple plug-n-play scanning + presentation option, see EasyReadingViewController. The LRDetection is the central class for listen detecton related events.
 
 Typical usage involves the following workflow
 
 1. In your view controller, set the delegate on the shared instance : `[[LRManager sharedManager] setDelegate:self]`
 2. Retrieve the video preview layer from LRManager and insert it into your preview subview
 3. Authorize the SDK using -authorizeWithClientID:secret:success:failure: , and begin scanning once the authorization is completed successfully
 
 @since 2.0.0
 */
@interface LRDetection : NSObject

/**
 The delegate that will receive notifications when the payoff is found and when the payoff has been resolved or we have an error.
 
 @since 2.0.0
 */
@property (nonatomic, weak) id<LRDetectionDelegate> delegate;

+ (LRDetection*) sharedInstance;
- (void)cancelPayoffRetrieval;

@end
