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

#import "PGMetarPayoffFeedbackViewController.h"

@interface PGMetarPayoffFeedbackViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (assign, nonatomic) BOOL hintVisible;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)clickBackArrow:(id)sender;
- (IBAction)clickSubmitButton:(id)sender;

@end

@implementation PGMetarPayoffFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textView.text = NSLocalizedString(@"Here’s what I think about this experience…",nil);
    self.textView.textColor = [UIColor lightGrayColor];
    self.hintVisible = YES;
    
    self.submitButton.layer.cornerRadius = 5;
    self.submitButton.layer.masksToBounds = YES;
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)clickBackArrow:(id)sender {
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }];
}

- (IBAction)clickSubmitButton:(id)sender {
    [self.textView resignFirstResponder];
    
    [self clickBackArrow:self];
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    if (self.hintVisible) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

@end
