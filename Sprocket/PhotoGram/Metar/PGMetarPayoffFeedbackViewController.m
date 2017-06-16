//
//  PGMetarPayoffFeedbackViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 6/15/17.
//  Copyright © 2017 HP. All rights reserved.
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
    // Do any additional setup after loading the view from its nib.
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
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
