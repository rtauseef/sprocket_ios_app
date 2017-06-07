//
//  PGAurasmaTrackingViewDelegate.h
//  Sprocket
//
//  Created by Alex Walter on 07/06/2017.
//  Copyright © 2017 HP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PGAurasmaViewController;

@protocol PGAurasmaTrackingViewDelegate <NSObject>

- (void)finishedTracking:(PGAurasmaViewController *)controller;

@end
