//
//  PGPayoffFullScreenTmpViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/17/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGPayoffFullScreenTmpViewController.h"

@interface PGPayoffFullScreenTmpViewController ()

@property (assign, nonatomic) BOOL viewJustLoaded;

@end

@implementation PGPayoffFullScreenTmpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewJustLoaded = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (!self.viewJustLoaded) {
        [super viewDidAppear:animated];

        if ([self.delegate respondsToSelector:@selector(tmpViewIsBack)]) {
            [self.delegate tmpViewIsBack];
        }
    } else {
        self.viewJustLoaded = NO;
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

@end
