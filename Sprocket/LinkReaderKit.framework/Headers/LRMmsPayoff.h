//
//  HPMmsPayoff.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRPayoff.h"

/**
 Represents an MMS message, commonly found in QRcodes. 
 
 @see LRSmsPayoff
 
 @since 1.0
 */
@interface LRMmsPayoff : NSObject <LRPayoff>

/**
 Recipient's phone number
 
 @since 1.0
 */
@property (nonatomic, readonly) NSString *phoneNumber;

/**
 MMS message body
 
 @since 1.0
 */
@property (nonatomic,readonly) NSString *message;


/**
 Create an instance of LRMmsPayoff with a given phone number and message

 @param phoneNumber (optional) recipient's phone number
 @param message     (optional) message body

 @return LRMmsPayoff
 
 @since 1.0
 */
- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber message:(NSString *)message;

@end
