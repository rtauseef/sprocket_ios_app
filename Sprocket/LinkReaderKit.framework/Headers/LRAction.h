//
//  LRAction.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LinkReaderKit/LRPayoff.h>

/**
 LRAction is the model representation of what will end up being a button on the screen with a specific action

 @since 1.0
 */
@interface LRAction : NSObject


/**
 NSDictionary representation of icon data
 
 @since 1.0
 */
@property (strong, readonly) NSDictionary *iconData;

/**
 NSString icon identifier

 @since 1.0
 */
@property (nonatomic, readonly) NSString *iconID;

/**
 NSDictionary representation of action raw data
 
 @since 1.0
 */
@property (nonatomic, readonly) NSDictionary *rawData;

/**
 LRAction label
 
 @since 1.0
 */
@property (strong, readonly) NSString* label;

/**
 LRPayoff object for this LRAction
 
 @since 1.0
 */
@property (strong, readonly)id<LRPayoff> payoff;

/**
 used in cases where order is important but not guaranteed

 @since 1.0
 */
@property (nonatomic, assign) NSInteger idx;


/**
 Creates an LRAction object with the LRPayoff object parsed from the raw payoff data 

 @param action     is the raw payoff data
 @param index      order in which this action should appear on the screen
 @param completion callback function
 
 @since 1.0
 */
+ (void)getLRActionWithPayoffFromDictionary:(NSDictionary *)action
                                     index:(NSInteger)index
                                 completion:(void(^)(LRAction* lrAction, NSInteger index, NSError* error))completion;




@end
