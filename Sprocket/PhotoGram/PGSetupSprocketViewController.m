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
#import "UIColor+HexString.h"


@interface PGSetupSprocketViewController()
@property (weak, nonatomic) IBOutlet PGAttributedLabel *step1LoadPaper;
@property (weak, nonatomic) IBOutlet PGAttributedLabel *step2PowerUp;
@property (weak, nonatomic) IBOutlet PGAttributedLabel *step3Connect;

@property (weak, nonatomic) IBOutlet UILabel *step1Content;
@property (weak, nonatomic) IBOutlet UILabel *step2Content;
@property (weak, nonatomic) IBOutlet UILabel *step3Content;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation PGSetupSprocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.trackableScreenName = @"Setup Sprocket Printer";
    self.closeButton.hidden = self.modalTransitionStyle != UIModalTransitionStyleCrossDissolve;
}

- (void)viewWillAppear:(BOOL)animated
{
    [PGSetupSprocketViewController setStepOneLabelText:self.step1LoadPaper];
    [PGSetupSprocketViewController setStepTwoLabelText:self.step2PowerUp];
    [PGSetupSprocketViewController setStepThreeLabelText:self.step3Connect];
    
    self.step1Content.text = [PGSetupSprocketViewController stepOneContentText];
    self.step2Content.text = [PGSetupSprocketViewController stepTwoContentText];
    self.step3Content.text = [PGSetupSprocketViewController stepThreeContentText];
}

+ (NSString *)stepOneContentText
{
    NSString *text = NSLocalizedString(@"Put the entire pack in the paper tray with barcode and HP logos facing down.", @"Instructions for loading paper");
    
    return text;
}

+ (NSString *)stepTwoContentText
{
    NSString *text = NSLocalizedString(@"Press and hold the power button until the LED turns white.", @"Instructions for turning a printer on");
    
    return text;
}

+ (NSString *)stepThreeContentText
{
    NSString *text = NSLocalizedString(@"From Bluetooth Settings, tap on “HP sprocket” to pair with the printer.", @"Instructions for connecting a phone to a printer via bluetooth");
    
    return text;
}

+ (void)setStepOneLabelText:(PGAttributedLabel *)label
{
    NSString *stepOne = NSLocalizedString(@"Step 1", @"Setup step 1 title");
    NSString *stepOneDesc = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Load Paper", @"Setup step 1 desc")];

    [PGSetupSprocketViewController setupStepLabel:label step:stepOne desc:stepOneDesc];
}

+ (void)setStepTwoLabelText:(PGAttributedLabel *)label
{
    NSString *stepTwo = NSLocalizedString(@"Step 2", @"Setup step 2 title");
    NSString *stepTwoDesc = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Power Up", @"Setup step 2 desc")];

    [PGSetupSprocketViewController setupStepLabel:label step:stepTwo desc:stepTwoDesc];
}

+ (void)setStepThreeLabelText:(PGAttributedLabel *)label
{
    NSString *stepThree = NSLocalizedString(@"Step 3", @"Setup step 3 title");
    NSString *stepThreeDesc = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Connect", @"Setup step 3 desc")];

    [PGSetupSprocketViewController setupStepLabel:label step:stepThree desc:stepThreeDesc];
}

+ (void)setupStepLabel:(PGAttributedLabel *)label step:(NSString *)step desc:(NSString *)desc
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:step attributes:nil];
    
    [attributedText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:desc]];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0096D6"] range:NSMakeRange(step.length, desc.length)];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:label.fontFamily size:label.fontSize] range:NSMakeRange(0, attributedText.length)];
    label.attributedText = attributedText;
}


- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
