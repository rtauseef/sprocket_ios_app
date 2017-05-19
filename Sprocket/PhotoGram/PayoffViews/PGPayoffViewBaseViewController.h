//
//  PGPayoffViewBaseViewController.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGMetarMedia.h"

@interface PGPayoffViewBaseViewController : UIViewController

@property (strong, nonatomic) NSString *viewTitle;
@property (strong, nonatomic) PGMetarMedia *metadata;

@end
