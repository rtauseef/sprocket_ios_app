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

#import "PGInterstitialAwarenessViewController.h"
#import "UIViewController+Trackable.h"
#import "NSLocale+Additions.h"

@interface PGInterstitialAwarenessViewController ()

@property (weak, nonatomic) IBOutlet UILabel *printLabel;
@property (weak, nonatomic) IBOutlet UILabel *enableLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation PGInterstitialAwarenessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trackableScreenName = @"Interstitial Awareness Screen";
    
    [self setLineHeight:self.printLabel height:1.1];
    [self setLineHeight:self.enableLabel height:1.1];
    
    if (![NSLocale isEnglish]) {
        self.backgroundImageView.image = [UIImage imageNamed:@"previewInterstitial"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)didTouchUpInsideCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setLineHeight:(UILabel *)label height:(CGFloat)height
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 1.0;
    paragraphStyle.lineHeightMultiple = height;
    paragraphStyle.alignment = label.textAlignment;
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, label.text.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, label.text.length)];

    label.attributedText = attributedString;
}

@end
