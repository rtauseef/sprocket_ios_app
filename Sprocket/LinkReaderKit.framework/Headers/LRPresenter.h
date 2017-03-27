//
//  LRPresenter.h
//  LinkReaderSDK
//
//  Created by LivePaper on 7/11/16.
//  Copyright © 2016 HP. All rights reserved.
//

#ifndef LRPresenter_h
#define LRPresenter_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <LinkReaderKit/LRPayoff.h>

@protocol LRPresenterDelegate <NSObject>

@optional
/**
 Called before the payoff presentation will appear.
 
 @since 1.0
 */
-(void)presentationWillAppear;

/**
 Called once the payoff presentation animation has completed.
 
 @since 1.0
 */
-(void)presentationDidAppear;

/**
 Called when the payoff presentation has been signaled to dismiss.
 
 @since 1.0
 */
-(void)presentationWillDismiss;

/**
 Called when the payoff presentation dismissal is complete.
 
 @since 1.0
 */
-(void)presentationDidDismiss;

@end

@interface LRPresenter: NSObject

/**
 The delegate that will receive notifications when payoff will be presented/dismissed.
 
 @since 1.0
 */
@property (nonatomic, weak) id<LRPresenterDelegate> delegate;


/**
 Queries whether or not the LinkReaderSDK is able to present built-in payoffs. Common reasons for being unable to present payoffs include authorization issues or non-passing internal checks. It's important to check the returned value before attempting to call -presentPayoff:viewController:completion.
 
 @param payoff The LRPayoff you wish to present using LinkReaderKit's built-in presentation mechanism. In some cases, a generic LRPayoff may be returned via -didFindPayoff: , but the SDK will have enough information to properly present the appropriate UI.
 
 @return YES if it can present the payoff; NO if it is unable
 
 @since 1.0
 */
- (BOOL)canPresentPayoff:(id<LRPayoff> ) payoff;


/**
 Present the payoff using the appropriate LinkReaderKit presentation mechanism.
 
 If you wish to use build-in LinkReaderKit payoff presentation mechanisms, call this method and provide the view controller you wish to act as the parent view controller. If you wish to use your own presentation method, there is no need to use this method.
 
 
 @param payoff  An instance of a LRPayoff or subclass. In some cases, a generic LRPayoff may be returned via -didFindPayoff: , but the SDK will have enough information to properly present the appropriate UI.
 @param viewController The UIViewController subclass that should be used for payoff UI presentation.
 
 @see -presentationWillAppear
 @see -presentationDidAppear
 @see -canPresentPayoff:
 
 @since 1.0
 */
- (void)presentPayoff:(id<LRPayoff> )payoff viewController:(UIViewController *)viewController;

@end

#endif /* LRPresenter_h */
