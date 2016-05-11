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

#import "PGHighQualityTextView.h"

CGFloat const kScale = 10;

@implementation PGHighQualityTextView

- (id)initWithTextView:(UITextView *)textView
{
    self = [super init];
    if (self) {
        [self setupWithTextView:textView];
    }
    
    return self;
}

- (void)setupWithTextView:(UITextView *)textView
{
    self.delegate = self;
    
    self.frame = CGRectMake(CGRectGetMinX(textView.frame),
                            CGRectGetMinY(textView.frame),
                            CGRectGetWidth(textView.frame) * kScale,
                            CGRectGetHeight(textView.frame) * kScale);
    
    self.minimumZoomScale = 1 / kScale;
    
    CGRect textViewContainerFrame = CGRectMake(0,
                                               0,
                                               CGRectGetWidth(self.frame),
                                               CGRectGetHeight(self.frame));
    
    _textViewContainer = [[UIView alloc] initWithFrame:textViewContainerFrame];
    self.textViewContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textViewContainer];
    
    UITextView *highQualityTextView = [[UITextView alloc] initWithFrame:self.textViewContainer.bounds];
    highQualityTextView.layoutManager.allowsNonContiguousLayout = NO;
    highQualityTextView.contentInset = UIEdgeInsetsZero;
    highQualityTextView.textContainerInset = UIEdgeInsetsZero;
    highQualityTextView.font = [textView.font fontWithSize:(textView.font.pointSize * kScale)];
    highQualityTextView.textAlignment = textView.textAlignment;
    highQualityTextView.backgroundColor = textView.backgroundColor;
    highQualityTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    highQualityTextView.text = textView.text;
    highQualityTextView.textColor = textView.textColor;
    highQualityTextView.contentOffset = CGPointMake(textView.contentOffset.x * kScale, textView.contentOffset.y * kScale);
    [self.textViewContainer addSubview:highQualityTextView];
    
    self.zoomScale = self.minimumZoomScale;
}

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.textViewContainer;
}

@end
