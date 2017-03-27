//
//  HPSmsPayoff.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRPayoff.h"

/**
 Represents an SMS message. @see LRMmsPayoff
 
 @since 1.0
 */
@interface LRSmsPayoff : NSObject <LRPayoff>

/**
 The recipient's phone number
 
 @since 1.0
 */
@property (nonatomic, readonly) NSString *phoneNumber;

/**
 The message body
 
 @since 1.0
 */
@property (nonatomic,readonly) NSString *message;

/**
 Initializer

 @param phoneNumber (optional) Recipient's phone number
 @param message     (optional) Message body

 @return LRSmsPayoff
 
 @since 1.0
 */
- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber message:(NSString *)message;

@end
