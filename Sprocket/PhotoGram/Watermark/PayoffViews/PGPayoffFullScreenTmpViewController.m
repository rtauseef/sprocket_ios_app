//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
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

@end
