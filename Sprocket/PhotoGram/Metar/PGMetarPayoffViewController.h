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
@property (strong, nonatomic) NSURL *externalLinkURL;

- (IBAction)closeButtonClick:(id)sender;
- (void) getMetadataFromMetar;
- (void) updateCurrentViewLabel: (NSString *) name forView: (UIViewController *) view;

@end
