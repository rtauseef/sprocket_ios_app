
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

#import "PGSwipeCoachMarksView.h"
#import "UIFont+Style.h"

#define SWIPE_VELOCITY 500

@interface PGSwipeCoachMarksView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHorizontalCenterLayoutContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidthLayoutContraint;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation PGSwipeCoachMarksView

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma marks - Gesture recognizers

- (void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{    
    if ((gestureRecognizer.state == UIGestureRecognizerStateBegan) || (gestureRecognizer.state == UIGestureRecognizerStateChanged)) {
        
        CGPoint translate = [gestureRecognizer translationInView:self.contentView];
        self.contentViewHorizontalCenterLayoutContraint.constant = -translate.x;
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat velocityX = [gestureRecognizer velocityInView:self.contentView].x;

        if (velocityX > SWIPE_VELOCITY) {
            [self swipeRightAndDismiss];

        } else if (velocityX < -SWIPE_VELOCITY) {
            [self swipeLeftAndDismiss];
        } else {
            if (self.contentViewHorizontalCenterLayoutContraint.constant > ([UIScreen mainScreen].bounds.size.width / 2)) {
                [self swipeLeftAndDismiss];
            } else if (self.contentViewHorizontalCenterLayoutContraint.constant < (-[UIScreen mainScreen].bounds.size.width / 2)) {
                [self swipeRightAndDismiss];
            } else {
                [self swipeToOriginalPosition];
            }
        }
        
    }
}

#pragma marks - Utils

- (void)swipeLeftAndDismiss
{
    [self layoutIfNeeded];
    self.contentViewHorizontalCenterLayoutContraint.constant = [UIScreen mainScreen].bounds.size.width;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_SWIPE_COACH_MARKS_NOTIFICATION object:nil];
    }];
}

- (void)swipeRightAndDismiss
{
    [self layoutIfNeeded];
    self.contentViewHorizontalCenterLayoutContraint.constant = -[UIScreen mainScreen].bounds.size.width;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_SWIPE_COACH_MARKS_NOTIFICATION object:nil];
    }];
}

- (void)swipeToOriginalPosition
{
    [self layoutIfNeeded];
    self.contentViewHorizontalCenterLayoutContraint.constant = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)setup
{
    self.textLabel.font = [UIFont HPSimplifiedRegularFontWithSize:18.0f];
    self.textLabel.hidden = NO;
    
    self.contentViewWidthLayoutContraint.constant = [UIScreen mainScreen].bounds.size.width;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    
    [self.contentView addGestureRecognizer:panGestureRecognizer];
}

@end
