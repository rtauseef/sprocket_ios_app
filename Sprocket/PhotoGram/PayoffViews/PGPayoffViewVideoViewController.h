//
//  PGPayoffViewVideoViewController.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/15/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "PGPayoffViewBaseViewController.h"

@interface PGPayoffViewVideoViewController : PGPayoffViewBaseViewController

- (void) setVideoWithURL: (NSString *) strUrl;
- (void) setVideoWithAsset: (PHAsset *) asset;

@end
