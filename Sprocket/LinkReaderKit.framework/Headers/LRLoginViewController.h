//
//  LoginViewController.h
//  LinkReaderSDK
//
//  Created by Live Paper Pairing on 10/19/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LRLoginCompletion)(NSError * _Nullable error);


@interface LRLoginViewController : UIViewController

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;
- (nullable instancetype)init NS_UNAVAILABLE;

- (nullable instancetype)initWithCompletionBlock:(nullable LRLoginCompletion)completion;

@end
