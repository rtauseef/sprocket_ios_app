//
//  LRDetection.h
//  LinkReaderSDK
//
//  Created by LivePaper on 7/12/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRPayoff.h"

/**
 The domain string for errors that occur when LinkReaderSDK is trying to retrieve the experience related with a QRCode or a Watermark. See LRPayoffError for error types.
 
 @since 3.0
 */
FOUNDATION_EXPORT NSString *const LRPayoffResolverErrorDomain;

/**
 Error codes for LRPayoffResolverErrorDomain.
 
 @since 2.0.0
 */
typedef NS_ENUM(NSInteger, LRPayoffResolverError) {
    /**
     A server error occurred when retrieving the payoff
     
     @since 2.0
     */
    LRPayoffResolverErrorServerError,
    /**
     Trigger expired or not linked to a payoff
     
     @since 2.0
     */
    LRPayoffResolverErrorPayloadNotFound,
    /**
     The trigger value was not recognized by the Link server
     
     @since 2.0
     */
    LRPayoffResolverErrorPayloadOutOfRange,
    /**
     The server rejected the resolver request
     
     @since 2.0
     */
    LRPayoffResolverErrorBadResolveRequest,
    /**
     There was a network error while attempting to retrieve the content
     
     @since 2.0
     */
    LRPayoffResolverErrorConnectionError,
    /**
     The request to retrieve content was canceled by calling 'cancelPayoffRetrieval'
     
     @since 2.0
     */
    LRPayoffResolverErrorRequestCancelled,
    /**
     The internet connection is not available before making the resolver request
     
     @since 2.0
     */
    LRPayoffResolverErrorNetworkConnectionLost,
    /**
     The resolver request timed out
     
     @since 2.0
     */
    LRPayoffResolverErrorNetworkRequestTimedOut,
    /**
     The applicaiton is not authorized to retrieve the resolver data
     
     @since 2.0
     */
    LRPayoffResolverErrorNotAuthorized
};


/**
 The domain string for errors that occur when LinkReaderSDK is trying to parse the experience related with a QRCode or a Watermark. See LRPayoffError for error types.
 
 @since 3.0
 */
FOUNDATION_EXPORT NSString *const LRPayoffErrorDomain;

/**
 Error codes for LRPayoffErrorDomain.
 
 @since 2.0.0
 */
typedef NS_ENUM(NSInteger, LRPayoffError) {
    /**
     The payoff is not present in the response data
     
     @since 2.0
     */
    LRPayoffErrorPayoffNotPresentInData,
    /**
     The payoff data is not valid
     
     @since 2.0
     */
    LRPayoffErrorInvalidPayoffData,
    /**
     The payoff type is not recognized by the LinkReaderSDK
     
     @since 2.0
     */
    LRPayoffErrorMissingOrUnknownPayoffType,
    /**
     The payoff data is not in the expected structure or format
     
     @since 2.0
     */
    LRPayoffErrorInvalidPayoffFormat
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
     
     @since 1.2.0
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
- (void)didFindPayoff:(id<LRPayoff>)payoff;

/**
 When a payload has been detected but an error has ocurred while trying to obtain the payoff linked to it, the delegate will be provided with the error. The error domain will be 'LRPayoffResolverErrorDomain'
 
 @param error an error produced while attempting to obtain the payoff.
 
 @since 2.0.0
 */
- (void)errorOnPayoffResolving:(NSError *)error;

/**
 When a payload has been detected, LinkReader obtained a payoff linked to it and an error has ocurred when parsing it, the delegate will be provided with the error. The error domain will be 'LRPayoffErrorDomain'
 
 @param error     an error produced while attempting to parse the payoff.
 
 @since 2.0.0
 */
- (void)errorOnPayoffParsing:(NSError *)error;


@optional

/**
 When a QRcode or Watermark has been detected, the delegate will be provided with the type of payload read.
 
 
 @param triggerType    type of mark read.
 
 @since 2.0.0
 */
- (void)didFindTrigger:(LRTriggerType)triggerType;

@end

#pragma mark -

/**
 The primary purpose of LRDetection is to allow the developer user to have finer-grained control over interaction with the LinkReaderSDK. If you wish to use a simple plug-n-play scanning + presentation option, see `EasyReadingViewController`.
 
 The LRDetection is the central class for listen detecton related events.
 
 Please refer to the LRManager class for instructions on how to use the `LRManager`/LRDetection/`LRCaptureManager`/`LRPresenter` classes.
 
 @since 2.0.0
 */
@interface LRDetection : NSObject

/**
 The delegate that will receive notifications when the payoff is found and when the payoff has been resolved or we have an error.
 
 @since 2.0.0
 */
@property (nonatomic, weak) id<LRDetectionDelegate> delegate;

/**
 Get a shared instance of the LRDetection.
 
 @return The LRDetection shared instance
 
 @since 1.0
 */
+ (LRDetection*)sharedInstance;
    
/**
 Cancels the retrieval of a payoff.
 
 @since 2.0.0
 */
- (void)cancelPayoffRetrieval;

@end
