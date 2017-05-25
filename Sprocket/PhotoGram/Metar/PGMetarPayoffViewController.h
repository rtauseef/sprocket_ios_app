//
//  PGMetarPayoffViewController.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/15/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGPayoffMetadata.h"
#import "PGPayoffViewBaseViewController.h"

@interface PGMetarPayoffViewController : UIViewController

@property (strong, nonatomic) PGPayoffMetadata *metadata;

- (IBAction)closeButtonClick:(id)sender;
- (void) getMetadataFromMetar;
- (void) updateCurrentViewLabel: (NSString *) name forView: (PGPayoffViewBaseViewController *) view;

@end
