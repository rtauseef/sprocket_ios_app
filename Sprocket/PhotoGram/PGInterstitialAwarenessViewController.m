//
//  PGInterstitialAwarenessViewController.m
//  Sprocket
//
//  Created by Susy Snowflake on 12/7/16.
//  Copyright © 2016 HP. All rights reserved.
//

#import "PGInterstitialAwarenessViewController.h"
#import "UIViewController+Trackable.h"

@interface PGInterstitialAwarenessViewController ()

@end

@implementation PGInterstitialAwarenessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trackableScreenName = @"Interstitial Awareness Screen";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didTouchUpInsideCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
