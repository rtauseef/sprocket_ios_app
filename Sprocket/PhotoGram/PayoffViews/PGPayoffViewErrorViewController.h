//
//  PGPayoffViewErrorViewController.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/16/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGMetarPayoffViewController.h"
#import "PGPayoffViewBaseViewController.h"

@interface PGPayoffViewErrorViewController : PGPayoffViewBaseViewController

@property (strong, nonatomic) PGMetarPayoffViewController* parentVc;
@property (strong, nonatomic) NSString *errorCustomMessage;
@property (assign, nonatomic) BOOL shouldHideRetry;

@end
