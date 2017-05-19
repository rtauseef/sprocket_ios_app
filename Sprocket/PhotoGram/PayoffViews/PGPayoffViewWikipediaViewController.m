//
//  PGPayoffViewWikipediaViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGPayoffViewWikipediaViewController.h"
#import "PGMetarPage.h"

@interface PGPayoffViewWikipediaViewController ()

@property (weak, nonatomic) IBOutlet UILabel *articleNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *articleDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *showMoreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *articleDescriptionHeightConstraint;
- (IBAction)didClickArticleDescriptionShowMore:(id)sender;
@property (assign, nonatomic) BOOL descriptionExpanded;
@property (assign, nonatomic) int currentIndex;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

#define kShortDescriptionFixedHeight 200.0

@implementation PGPayoffViewWikipediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.viewTitle = NSLocalizedString(@"Wikipedia", nil);
    
    self.currentIndex = 0;
    [self renderPageAtIndex:_currentIndex];
}

- (void)viewDidAppear:(BOOL)animated {
    UILongPressGestureRecognizer *longPressWikipedia = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressWikipedia:)];
    longPressWikipedia.minimumPressDuration = 1.0f;
    [self.view addGestureRecognizer:longPressWikipedia];
}

- (void)handleLongPressWikipedia:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.currentIndex++;
        if (![self renderPageAtIndex:_currentIndex]) {
            self.currentIndex = 0;
            [self renderPageAtIndex:self.currentIndex];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {

    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([[self.view gestureRecognizers] count] > 0) {
        [self.view removeGestureRecognizer:[[self.view gestureRecognizers] firstObject]];
    }
}

- (BOOL) renderPageAtIndex: (int) index {
    if (self.metadata != nil) {
        NSDictionary *wikipediaAllLang = self.metadata.location.content.wikipedia.pages;
        // TODO: other languages
        
        NSArray *enPages = [wikipediaAllLang objectForKey:@"en"];
        
        if (enPages != nil) {
            
            if (index < [enPages count]) {
                PGMetarPage *page = [enPages objectAtIndex:index];
                self.descriptionExpanded = NO;
                self.articleNameLabel.text = page.title;
                self.articleDescriptionTextView.text = page.text;
                
                // Article Description
                [self.showMoreButton setTitle:NSLocalizedString(@"Show more",nil) forState:UIControlStateNormal];
                self.descriptionExpanded = NO;
                CGRect newFrame = self.articleDescriptionTextView.frame;
                newFrame.size.height = kShortDescriptionFixedHeight;
                
                CGFloat fixedWidth = self.articleDescriptionTextView.frame.size.width;
                CGSize newSize = [self.articleDescriptionTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
                
                if (newSize.height <= kShortDescriptionFixedHeight) {
                    self.showMoreButton.hidden = YES;
                } else {
                    self.showMoreButton.hidden = NO;
                }
                
                self.articleDescriptionHeightConstraint.constant = kShortDescriptionFixedHeight;
                [self.articleDescriptionTextView setNeedsLayout];
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"Y is %.2f",self.endLabel.frame.origin.y);
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.endLabel.frame.origin.y);
}
- (IBAction)didClickArticleDescriptionShowMore:(id)sender {
    if (self.descriptionExpanded) {
        [self.showMoreButton setTitle:NSLocalizedString(@"Show more",nil) forState:UIControlStateNormal];
        self.descriptionExpanded = NO;
        CGRect newFrame = self.articleDescriptionTextView.frame;
        newFrame.size.height = kShortDescriptionFixedHeight;
        
        self.articleDescriptionHeightConstraint.constant = kShortDescriptionFixedHeight;
    } else {
        [self.showMoreButton setTitle:NSLocalizedString(@"Show less",nil) forState:UIControlStateNormal];
        self.descriptionExpanded =  YES;
        CGFloat fixedWidth = self.articleDescriptionTextView.frame.size.width;
        CGSize newSize = [self.articleDescriptionTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = self.articleDescriptionTextView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        self.articleDescriptionTextView.frame = newFrame;
        
        self.articleDescriptionHeightConstraint.constant = newSize.height;
    }
    [self.articleDescriptionTextView setNeedsLayout];
}

@end
