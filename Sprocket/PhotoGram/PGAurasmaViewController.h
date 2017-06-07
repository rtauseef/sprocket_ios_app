//
//  PGAurasmaViewController.h
//  Sprocket
//
//  Created by Alex Walter on 06/06/2017.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PGAurasmaTrackingViewDelegate;

@interface PGAurasmaViewController : UIViewController

- (void)setClosingDelegate:(id<PGAurasmaTrackingViewDelegate>)closingDelegate;

@end
