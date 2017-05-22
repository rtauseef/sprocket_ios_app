//
//  PGPayoffViewImageViewController.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/15/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PGMetarMedia.h"
#import "PGPayoffViewBaseViewController.h"
#import "PGMetarPayoffViewController.h"

@interface PGPayoffViewImageViewController : PGPayoffViewBaseViewController

- (void)showImageSameDayAsDate: (NSDate *) date;
- (void)showImagesSameLocation: (CLLocation *) location;

@property (strong, nonatomic) PGMetarPayoffViewController *parentVc;

@end
