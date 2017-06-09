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

#import "PGPreviewDrawerViewController.h"
#import <MPBTPrintManager.h>

static NSInteger const kPGPreviewDrawerClosedDrawerHeight = 25;
static NSInteger const kPGPreviewDrawerHotAreaHeight = 50;
static NSInteger const kPGPreviewDrawerNumberOfCopiesLimit = 10;
static NSInteger const kPGPreviewDrawerRowHeight = 58;

@interface PGPreviewDrawerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *drawerButton;
@property (weak, nonatomic) IBOutlet UILabel *copiesLabel;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfJobsLabel;
@property (weak, nonatomic) IBOutlet UIView *printQueueView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *printQueueViewHeight;

@property (strong, nonatomic) NSTimer *queueCountTimer;

@end

@implementation PGPreviewDrawerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showCopies = YES;
    self.showTiling = NO;
    [self configureShowPrintQueue];

    self.queueCountTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshQueueCount) userInfo:nil repeats:YES];

    self.numberOfCopies = 1;
    
    self.drawerButton.clipsToBounds = NO;
    self.drawerButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.drawerButton.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.drawerButton.layer.shadowOpacity = 0.8f;
    self.drawerButton.layer.shadowRadius = 6.0f;
    
    [self updateCopyLabelAndButtons];
}

- (void) viewDidUnload
{
    [self.queueCountTimer invalidate];
    self.queueCountTimer = nil;
}

- (void)setShowPrintQueue:(BOOL)showPrintQueue
{
    if (_showPrintQueue == showPrintQueue && self.printQueueView.isHidden == !showPrintQueue) {
        return;
    }
    _showPrintQueue = showPrintQueue;

    self.printQueueView.hidden = !showPrintQueue;
    if (showPrintQueue) {
        self.printQueueViewHeight.constant = kPGPreviewDrawerRowHeight;
    } else {
        self.printQueueViewHeight.constant = 0;
    }
}

- (IBAction)didTapDrawerButton:(id)sender
{
    self.isOpened = !self.isOpened;
    
    if ([self.delegate respondsToSelector:@selector(pgPreviewDrawer:didTapButton:)]) {
        [self.delegate pgPreviewDrawer:self didTapButton:sender];
    }
}

- (BOOL)isOpened
{
    if (!_isOpened) {
        _isOpened = NO;
    }
    
    return _isOpened;
}

- (CGFloat)drawerHeight
{
    if (self.isOpened) {
        return [self drawerHeightOpened];
    } else if (self.isPeeking) {
        return [self drawerHeightPeeking];
    } else {
        return [self drawerHeightClosed];
    }
}

- (CGFloat)drawerHeightOpened
{
    NSInteger numberOfRowsActive = 0;
    if (self.showPrintQueue || self.alwaysShowPrintQueue) {
        numberOfRowsActive++;
    }

    if (self.showCopies) {
        numberOfRowsActive++;
    }

    if (self.showTiling) {
        numberOfRowsActive++;
    }
    
    return kPGPreviewDrawerClosedDrawerHeight + (kPGPreviewDrawerRowHeight * numberOfRowsActive) + kPGPreviewDrawerHotAreaHeight;
}

- (CGFloat)drawerHeightPeeking
{
    return kPGPreviewDrawerClosedDrawerHeight + kPGPreviewDrawerRowHeight + kPGPreviewDrawerHotAreaHeight;
}

- (CGFloat)drawerHeightClosed
{
    return kPGPreviewDrawerClosedDrawerHeight + kPGPreviewDrawerHotAreaHeight;
}

- (void)updateCopyLabelAndButtons
{
    NSString *copyString = NSLocalizedString(@"Copy", @"Number of Copies for printing");
    if (self.numberOfCopies > 1) {
        copyString = NSLocalizedString(@"Copies", @"Number of Copies for printing");
    }
    
    self.copiesLabel.text = [NSString stringWithFormat:@"%ld %@", (long)self.numberOfCopies, copyString];
    self.plusButton.enabled = self.numberOfCopies != kPGPreviewDrawerNumberOfCopiesLimit;
    self.minusButton.enabled = self.numberOfCopies != 1;
}

- (void)configureShowPrintQueue
{
    if (self.alwaysShowPrintQueue){
        if (!self.showPrintQueue) {
            self.showPrintQueue = YES;
        }
        return;
    }

    NSInteger count = [[MPBTPrintManager sharedInstance] queueSize];
    if (count <= 0) {
        self.showPrintQueue = NO;
    } else if (count > 0) {
        self.showPrintQueue = YES;
    }
}

- (void)refreshQueueCount
{
    NSInteger count = [[MPBTPrintManager sharedInstance] queueSize];
    
    if (count <= 0 && (self.isOpened || self.isPeeking)) {
        if ([self.delegate respondsToSelector:@selector(pgPreviewDrawerDidClearQueue:)]) {
            [self.delegate pgPreviewDrawerDidClearQueue:self];
        }
    }

    self.numberOfJobsLabel.text = [NSString stringWithFormat:@"%li", (long)count];
}

#pragma mark - Buttons Handlers

- (IBAction)plusTapped:(id)sender
{
    if (self.numberOfCopies < kPGPreviewDrawerNumberOfCopiesLimit) {
        self.numberOfCopies++;
    }
    
    [self updateCopyLabelAndButtons];
}

- (IBAction)minusTapped:(id)sender
{
    if (self.numberOfCopies >= 1) {
        self.numberOfCopies--;
    }
    
    [self updateCopyLabelAndButtons];
}

#pragma mark - Gesture Recognizers

- (IBAction)handlePan:(UIPanGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(pgPreviewDrawer:didDrag:)]) {
        [self.delegate pgPreviewDrawer:self didDrag:gesture];
    }
}

- (IBAction)printQueueTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(pgPreviewDrawerDidTapPrintQueue:)]) {
        [self.delegate pgPreviewDrawerDidTapPrintQueue:self];
    }
}

@end
