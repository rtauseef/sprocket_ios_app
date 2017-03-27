//
//  LoginViewController.h
//  LinkReaderSDK
//
//  Created by Live Paper Pairing on 10/19/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LRLoginCompletion)(NSError * _Nullable error);

/**
 A class that enables Link Technology users to login with their Link Accounts
 
 @since 3.0
 */
@interface LRLoginViewController : UIViewController

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 Initializes a LRLoginViewController instance
 
 @param completion A completion block that will be called with the result of the user authentication
 
 @since 3.0
 */
- (nullable instancetype)initWithCompletionBlock:(nullable LRLoginCompletion)completion;

@end
