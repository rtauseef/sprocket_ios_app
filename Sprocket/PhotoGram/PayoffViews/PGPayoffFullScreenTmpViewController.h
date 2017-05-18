//
//  PGPayoffFullScreenTmpViewController.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/17/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PGPayoffFullScreenTmpViewControllerDelegate <NSObject>
@optional
- (void) tmpViewIsBack;
@end

@interface PGPayoffFullScreenTmpViewController : UIViewController

@property (nonatomic, weak) id <PGPayoffFullScreenTmpViewControllerDelegate> delegate;

@end
