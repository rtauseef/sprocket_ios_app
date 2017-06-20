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
