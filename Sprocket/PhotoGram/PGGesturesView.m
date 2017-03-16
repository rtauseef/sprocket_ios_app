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

#import "PGGesturesView.h"
#import "UIImage+imageResize.h"
#import "UIView+Background.h"

static CGFloat const kMinimumZoomScale = 1.0f;
static CGFloat const kMaximumZoomScale = 4.0f;
static CGFloat const kAnimationDuration = 0.3f;
static CGFloat const kMarginOfError = .01f;
static CGFloat const kLoadingIndicatorSize = 50;

@interface PGGesturesView ()

@property (nonatomic, assign) UIViewContentMode imageContentMode;
@property (nonatomic, strong) UIView *selectionView;
@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) NSTimer *zoomTimer;

@end

@implementation PGGesturesView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
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

- (void)setup
{
    self.accessibilityIdentifier = @"GestureView";
    
    self.imageContentMode = UIViewContentModeScaleAspectFill;
    
    self.minimumZoomScale = kMinimumZoomScale;
    self.maximumZoomScale = kMaximumZoomScale;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.accessibilityIdentifier = @"GestureScrollView";
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.minimumZoomScale = self.minimumZoomScale;
    self.scrollView.maximumZoomScale = self.maximumZoomScale;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.canCancelContentTouches = NO;

    self.backgroundColor = [UIColor whiteColor];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    self.doubleTapBehavior = PGGesturesDoubleTapReset;
    self.totalRotation = 0.0F;
    
    [self addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.accessibilityIdentifier = @"GestureImageView";
    self.imageView.userInteractionEnabled = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.scrollView addSubview:self.imageView];
    
    self.selectionView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectionView.backgroundColor = [UIColor blackColor];
    self.selectionView.alpha = 0.6;
    self.selectionView.userInteractionEnabled = NO;
    self.selectionView.hidden = YES;
    
    [self addSubview:self.selectionView];
    
    NSUInteger checkmarkWidth = 37;
    self.checkmark = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - (checkmarkWidth + 10), self.bounds.size.height - (checkmarkWidth + 10), checkmarkWidth, checkmarkWidth)];
    self.checkmark.image = [UIImage imageNamed:@"Check_Inactive1"];
    self.checkmark.highlightedImage = [UIImage imageNamed:@"Check"];
    
    [self addSubview:self.checkmark];
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.bounds.size.width / 2) - (kLoadingIndicatorSize / 2), (self.bounds.size.height / 2) - (kLoadingIndicatorSize / 2), kLoadingIndicatorSize, kLoadingIndicatorSize)];
    self.loadingIndicator.hidesWhenStopped = YES;
    self.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:self.loadingIndicator];
    
    self.isSelected = YES;
    self.isMultiSelectImage = NO;
    
    self.clipsToBounds = YES;
    
    [self enableGestures];
}

- (void)enableGestures
{
    self.scrollView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *regularTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regularTapRecognized:)];
    regularTapGesture.numberOfTapsRequired = 1;
    regularTapGesture.numberOfTouchesRequired = 1;
    regularTapGesture.delegate = self;
    regularTapGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:regularTapGesture];

    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 2;
    doubleTapGesture.delegate = self;
    [self.scrollView addGestureRecognizer:doubleTapGesture];
    
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGestureRecognized:)];
    rotateGesture.delegate = self;
    [self.scrollView addGestureRecognizer:rotateGesture];
    
    [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:doubleTapGesture];
    [regularTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
}

- (void)setIsMultiSelectImage:(BOOL)isMultiSelectImage
{
    _isMultiSelectImage = isMultiSelectImage;
    
    self.checkmark.hidden = !isMultiSelectImage;
    
    [self.loadingIndicator startAnimating];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    self.selectionView.hidden = isSelected;
    [self.checkmark setHighlighted:isSelected];
}

#pragma mark - Getter & Setters

- (void)setAllowGestures:(BOOL)allowGestures
{
    _allowGestures = allowGestures;
    
    if (!allowGestures) {
        self.scrollView.scrollEnabled = NO;
        self.scrollView.userInteractionEnabled = NO;
        for (UIGestureRecognizer *gesture in self.scrollView.gestureRecognizers) {
            if (![gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [self.scrollView removeGestureRecognizer:gesture];
            }
        }
    }
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale
{
    _minimumZoomScale = minimumZoomScale;
    self.scrollView.minimumZoomScale = minimumZoomScale;
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale
{
    _maximumZoomScale = maximumZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
}

- (void)setImage:(UIImage *)image
{
    _media.image = image;
    _editedImage = image;
    
    self.imageView.image = image;
    [self.loadingIndicator stopAnimating];
}

#pragma mark - Helpers

- (void)rotate:(CGFloat)radians
{
    self.totalRotation += radians;
    
    self.scrollView.transform = CGAffineTransformRotate(self.scrollView.transform, radians);
}

- (void)adjustContentOffset
{
    if (!(self.imageView.frame.size.width > self.scrollView.bounds.size.width + kMarginOfError) &&
        !(self.imageView.frame.size.height > self.scrollView.bounds.size.height + kMarginOfError)) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.scrollView.contentOffset = CGPointMake((self.imageView.frame.size.width - self.scrollView.bounds.size.width) / 2,
                                                        (self.imageView.frame.size.height - self.scrollView.bounds.size.height) / 2);
        }];
    }
    
    if ([self.delegate respondsToSelector:@selector(imageEdited:)]) {
        [self.delegate imageEdited:self];
    }
}

- (UIImage *)screenshotImage
{
    BOOL isCheckmarkHidden = self.checkmark.hidden;
    self.checkmark.hidden = YES;
    
    UIImage *image = [super screenshotImage];
    self.checkmark.hidden = isCheckmarkHidden;
    
    return image;
}

- (void)zoomTimer:(NSTimer *)timer
{
    self.editedImage = [self screenshotImage];
    [self.zoomTimer invalidate];
    self.zoomTimer = nil;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)rotateGestureRecognized:(UIRotationGestureRecognizer *)recognizer
{
    [self rotate:recognizer.rotation];
    recognizer.rotation = 0;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.editedImage = [self screenshotImage];
    }
}

- (void)regularTapRecognized:(UITapGestureRecognizer *)recognizer
{
    
}

- (void)doubleTapRecognized:(UITapGestureRecognizer *)recognizer
{
    if (UIViewContentModeScaleAspectFill == self.imageContentMode) {
        self.imageContentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.imageContentMode = UIViewContentModeScaleAspectFill;
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.scrollView.transform = CGAffineTransformIdentity;
        self.totalRotation = 0.0F;
    } completion:^(BOOL finished) {
        self.imageView.contentMode = self.imageContentMode;
        self.scrollView.contentMode = self.imageContentMode;
        self.editedImage = [self screenshotImage];
        self.scrollView.zoomScale = kMinimumZoomScale;
    }];
    
    self.editedImage = [self screenshotImage];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(handleLongPress:)]) {
            [self.delegate handleLongPress:self];
        }
    }
}


#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self adjustContentOffset];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (!self.zoomTimer) {
        self.zoomTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(zoomTimer:) userInfo:nil repeats:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self adjustContentOffset];
    self.editedImage = [self screenshotImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.editedImage = [self screenshotImage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.editedImage = [self screenshotImage];
}

#pragma mark - Photo position

- (CGPoint)offset
{
    return self.scrollView.contentOffset;
}

- (CGFloat)zoom
{
    return self.scrollView.zoomScale;
}

- (CGFloat)angle
{
    return atan2(self.scrollView.transform.b, self.scrollView.transform.a) * 180.0f / M_PI;
}

#pragma mark - Methods used only by Share Extension


- (void)adjustScrollAndImageView
{
    self.scrollView.zoomScale = kMinimumZoomScale;
    self.scrollView.transform = CGAffineTransformIdentity;
    self.scrollView.contentOffset = CGPointZero;
    
    self.imageView.transform = CGAffineTransformIdentity;
    
    self.scrollView.frame = self.frame;
    self.imageView.frame = self.frame;
}

@end
