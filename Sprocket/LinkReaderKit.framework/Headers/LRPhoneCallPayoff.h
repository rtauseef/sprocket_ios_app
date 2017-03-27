//
//  HPPhoneCallPayoff.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRPayoff.h"

/**
 Represents a phone number
 
 @since 1.0
 */
@interface LRPhoneCallPayoff : NSObject <LRPayoff>

/**
 Destination phone number
 
 @since 1.0
 */
@property (nonatomic, readonly) NSString *phoneNumber;

/**
 Initializes a LRPhoneCallPayoff object with a phone number
 
 @param phoneNumber The phone number to call

 @return An initialized LRPhoneCallPayoff instance.

 @since 1.0
 */
- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber;

@end
