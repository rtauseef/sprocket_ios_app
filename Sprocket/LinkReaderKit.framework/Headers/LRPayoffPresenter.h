//
//  HPPayoffPresenter.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LRPayoff.h"


@class LRPayoffPresenter;

/**
 
 @since 1.0
 */
@protocol LRPayoffPresenterDelegate <NSObject>
/**
 Method that will be called before the payoff gets dismissed
 
 @since 1.0
 */
-(void)payoffWillDismiss;

/**
 Method that will be called after the payoff gets dismissed
 
 @since 1.0
 */
-(void)payoffDidDismiss;

@end


/**
 
 @since 1.0
 */
@interface LRPayoffPresenter : NSObject

/**
 Payoff that will be displayed by the presenter
 
 @since 1.0
 */
@property (strong, nonatomic) id<LRPayoff> payoff;

/**
 Delegate object that will be informed when the payoff presenter gets dismissed
 
 @since 1.0
 */
@property (strong, nonatomic) id<LRPayoffPresenterDelegate> delegate;

/**
 Presents the payoff inside the a view controller
 @param parentViewController The view controller that will present the payoff
 @param finished A block that will be called when the payoff gets presented
 
 @since 1.0
 */
- (void) present:(UIViewController *)parentViewController completion:(void(^)(void))finished;

/**
 Method called to determine if the payoff presenter can present the current payoff
 @param payoff The current payoff that needs to be presented
 @return A BOOL value indicating if the presenter can present the payoff
 
 @since 1.0
 */
-(BOOL)canPresentPayoff:(id<LRPayoff> )payoff;

/**
 Notifies the delegate that the payoff presenter will get dismissed
 
 @since 1.0
 */
-(void)notifyWillDismiss;

/**
 Notifies the delegate that the payoff presenter got dismissed
 
 @since 1.0
 */
-(void)notifyDidDismiss;

@end
