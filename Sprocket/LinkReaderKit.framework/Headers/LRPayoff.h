//
//  LRPayoff.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>


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
+ (BOOL)isThisPayoffType:(id)payoffObject;


/**
 Parses the raw payoffObject and creates an instance of this LRPayoff subclass
 @discussion This must be implemented by the subclass.
 @param   payoffObject is the raw payoff
 @param   completion is the callback function called on completion
 
 @since 1.0
 */
+ (void)parsePayoff:(id)payoffObject completion:(void(^)(id<LRPayoff>  payoff, NSError * error))completion;

@end

