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

#import "PGSetupSprocketViewController.h"
#import "UIViewController+Trackable.h"
#import "PGAttributedLabel.h"
#import "UIColor+HexString.h"


@interface PGSetupSprocketViewController()
@property (weak, nonatomic) IBOutlet PGAttributedLabel *step1LoadPaper;
@property (weak, nonatomic) IBOutlet PGAttributedLabel *step2PowerUp;
@property (weak, nonatomic) IBOutlet PGAttributedLabel *step3Connect;

@end

@implementation PGSetupSprocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.trackableScreenName = @"Setup Sprocket Printer";
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *stepOne = NSLocalizedString(@"Step 1", @"Setup step 1 title");
    NSString *stepOneDesc = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Load Paper", @"Setup step 1 desc")];
    NSString *stepTwo = NSLocalizedString(@"Step 2", @"Setup step 2 title");
    NSString *stepTwoDesc = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Power Up", @"Setup step 2 desc")];
    NSString *stepThree = NSLocalizedString(@"Step 3", @"Setup step 3 title");
    NSString *stepThreeDesc = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Connect", @"Setup step 3 desc")];
    
    [self setupStepLabel:self.step1LoadPaper step:stepOne desc:stepOneDesc];
    [self setupStepLabel:self.step2PowerUp step:stepTwo desc:stepTwoDesc];
    [self setupStepLabel:self.step3Connect step:stepThree desc:stepThreeDesc];

}

- (void)setupStepLabel:(PGAttributedLabel *)label step:(NSString *)step desc:(NSString *)desc
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:step attributes:nil];
    
    [attributedText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:desc]];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0096D6"] range:NSMakeRange(step.length, desc.length)];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:label.fontFamily size:label.fontSize] range:NSMakeRange(0, attributedText.length)];
    label.attributedText = attributedText;
}

@end
