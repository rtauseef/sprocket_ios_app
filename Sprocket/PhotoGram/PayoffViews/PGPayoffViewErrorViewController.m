//
//  PGPayoffViewErrorViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/16/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGPayoffViewErrorViewController.h"

@interface PGPayoffViewErrorViewController ()
- (IBAction)didClickRetry:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *errorRetryButton;

@end

@implementation PGPayoffViewErrorViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldHideRetry = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldHideRetry) {
        self.errorRetryButton.hidden = YES;
    }
    
    if (self.errorCustomMessage) {
        self.errorLabel.text = self.errorCustomMessage;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didClickRetry:(id)sender {
    if (self.parentVc != nil) {
        [self.parentVc getMetadataFromMetar];
    }
}

@end
