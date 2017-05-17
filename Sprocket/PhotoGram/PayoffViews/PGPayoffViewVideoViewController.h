//
//  PGPayoffViewVideoViewController.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/15/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PGPayoffViewVideoViewController : UIViewController

- (void) setVideoWithURL: (NSString *) strUrl;
- (void) setVideoWithAsset: (PHAsset *) asset;

@end
