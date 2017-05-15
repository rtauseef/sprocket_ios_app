//
//  PGMetarPayoffViewController.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/15/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGPayoffMetadata.h"

@interface PGMetarPayoffViewController : UIViewController

@property (strong, nonatomic) PGPayoffMetadata *metadata;

- (IBAction)closeButtonClick:(id)sender;

@end
