//
//  LRPayoff.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LR_PAYOFF_ERROR_DOMAIN @"LRPayoffErrorDomain"

///**
// The payoff type is unknown or unparsable
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypeUnknown;
///**
// URL formats:
// http (standard URL)
// urlto
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypeWebURL;
///**
// Email formats:
// mailto
// matmsg
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypeEmail;
///**
// Phone number format:
// tel
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypePhoneNumber;
///**
// Contact Card formats:
// mecard
// bizcard
// vcard
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypeContact;
///**
// SMS formats:
// sms
// smsto
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypeSMS;
///**
// MMS formats:
// mms
// mmsto
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypeMMS;
///**
// Location format:
// geo
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypeLocation;
///**
// Event formats:
// vcalendar
// vevent
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypeEvent;
///**
// Rich payoff, type layout
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypeLayout;
///**
// Rich payoff, type share. Typically used as a Layout action
// 
// @since 1.0
// */
//extern NSString * const LRPayoffTypeShare;



@protocol LRPayoff <NSObject>

/**
 Returns a string representation of the payoff type
 @discussion This must be implemented by the subclass.
 @return String representation of the payoff's type
 
 @since 1.0
 */
- (NSString *)typeString;

/**
 Returns a description of the Payoff data, in human-readable form
 @discussion This must be implemented by the subclass.
 @return String description of the payoff data, in human-readable form
 
 @since 1.0
 */
- (NSString *)displayString;

/**
 This method returns true if this LRPayoff subclass knows how to parse the raw payoff
 @discussion This must be implemented by the subclass.
 @param  payoffObject is the raw payoff
 @return true if the payoffObject can be parsed into this LRPayoff subclass
 
 @since 1.0
 */
+(BOOL)isThisPayoffType:(id)payoffObject;


/**
 Parses the raw payoffObject and creates an instance of this LRPayoff subclass
 @discussion This must be implemented by the subclass.
 @param   payoffObject is the raw payoff
 @param   completion is the callback function called on completion
 @return  void
 
 @since 1.0
 */
+(void)parsePayoff:(id)payoffObject completion:(void(^)(id<LRPayoff>  payoff, NSError * error))completion;

@end

