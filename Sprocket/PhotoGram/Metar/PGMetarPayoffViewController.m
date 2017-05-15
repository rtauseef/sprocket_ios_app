//
//  PGMetarPayoffViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/15/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarPayoffViewController.h"
#import "PGMetarAPI.h"

@interface PGMetarPayoffViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation PGMetarPayoffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.metadata != nil && self.metadata.data != nil && [self.metadata.data objectForKey:kPGPayoffUUIDKey] != nil) {
        // resolve metadata
        [self.activityIndicator startAnimating];
        
        PGMetarAPI * api = [[PGMetarAPI alloc] init];
        
        [api authenticate:^(BOOL success) {
            if (success) {
                [api requestImageMetadataWithUUID:[self.metadata.data objectForKey:kPGPayoffUUIDKey] completion:^(NSError * _Nullable error, PGMetarMedia * _Nullable metarMedia) {
                    
                    NSLog(@"Got metar media info...");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicator stopAnimating];
                    });
                }];
            } else {
                NSLog(@"METAR API Auth Error");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                });
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
