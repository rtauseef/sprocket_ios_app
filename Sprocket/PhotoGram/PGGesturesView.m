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
static CGFloat const kMinimumPressDurationInSeconds = 0.35f;
static CGFloat const kAnimationDuration = 0.3f;
static CGFloat const kMarginOfError = .01f;
static CGFloat const kSquareImageAllowance = 10.0f;
static CGFloat const kLoadingIndicatorSize = 50;

@interface PGGesturesView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) UIViewContentMode imageContentMode;
@property (nonatomic, strong) UIView *selectionView;
@property (nonatomic, strong) UIImageView *checkmark;

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
    
    self.backgroundColor = [UIColor whiteColor];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    self.doubleTapBehavior = PGGesturesDoubleTapZoom;
    self.totalRotation = 0.0F;
    
    [self addSubview:self.scrollView];
    
    self.selectionView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectionView.backgroundColor = [UIColor blackColor];
    self.selectionView.alpha = 0.6;
    self.selectionView.userInteractionEnabled = NO;
    
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
    
    self.isSelected = NO;
    self.isMultiSelectImage = NO;
    
    self.clipsToBounds = YES;
    
    [self enableGestures];
}

- (void)enableGestures
{
    self.scrollView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapGesture];
    
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGestureRecognized:)];
    rotateGesture.delegate = self;
    [self.scrollView addGestureRecognizer:rotateGesture];
}

- (void)setIsMultiSelectImage:(BOOL)isMultiSelectImage
{
    _isMultiSelectImage = isMultiSelectImage;
    
    self.selectionView.hidden = !isMultiSelectImage;
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

-(void)setMaximumZoomScale:(CGFloat)maximumZoomScale
{
    _maximumZoomScale = maximumZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
}

- (void)setImage:(UIImage *)image forceContentMode:(BOOL)forceContentMode
{
    _image = image;

    [self.loadingIndicator stopAnimating];
    [self adjustScrollAndImageViewWithForceContentMode:forceContentMode];
}

- (void)adjustScrollAndImageViewWithForceContentMode:(BOOL)forceContentMode
{
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.accessibilityIdentifier = @"GestureImageView";
        self.imageView.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.imageView];
    }
    
    if (forceContentMode) {
        if (abs((int)self.image.size.width - (int)self.image.size.height) < kSquareImageAllowance) {
            self.imageContentMode = UIViewContentModeScaleAspectFit;
        } else {
            self.imageContentMode = UIViewContentModeScaleAspectFill;
        }
    }
    
    CGFloat scaleFactor = self.frame.size.width / self.image.size.width;
    
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleFactor, scaleFactor);
    self.imageView.transform = transform;
    
    self.imageView.image = self.image;
    self.imageView.contentMode = self.imageContentMode;

    CGSize imageFinalSize = [self.image imageFinalSizeAfterContentModeApplied:self.imageView.contentMode containerSize:self.scrollView.bounds.size];
    if (imageFinalSize.width && imageFinalSize.height) {
        self.imageView.frame = CGRectMake(0, 0, imageFinalSize.width, imageFinalSize.height);
    }

    self.scrollView.minimumZoomScale = scaleFactor * self.minimumZoomScale;
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(self.imageView.frame), CGRectGetMaxY(self.imageView.frame));
    self.scrollView.contentOffset = CGPointMake((imageFinalSize.width - self.scrollView.bounds.size.width) / 2,
                                                (imageFinalSize.height - self.scrollView.bounds.size.height) / 2);
}

- (void)adjustScrollAndImageView
{
    [self adjustScrollAndImageViewWithForceContentMode:YES];
}

- (void)setImage:(UIImage *)image
{
    [self setImage:image forceContentMode:YES];
}

#pragma mark - Helpers

- (void)rotate:(CGFloat)radians
{
    self.totalRotation += radians;
    
    self.scrollView.transform = CGAffineTransformRotate(self.scrollView.transform, radians);
}

- (void)zoom:(CGPoint)pointInView zoomScale:(CGFloat)zoomScale animated:(BOOL)animated
{
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat width = scrollViewSize.width / zoomScale;
    CGFloat height = scrollViewSize.height / zoomScale;
    CGFloat x = pointInView.x - (width / 2.0f);
    CGFloat y = pointInView.y - (height / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, width, height);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:animated];
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

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)rotateGestureRecognized:(UIRotationGestureRecognizer *)recognizer
{
    [self rotate:recognizer.rotation];
    recognizer.rotation = 0;
}

- (void)doubleTapRecognized:(UITapGestureRecognizer*)recognizer
{
    if (PGGesturesDoubleTapZoom == self.doubleTapBehavior) {
        CGPoint pointInView = [recognizer locationInView:self.imageView];
        CGFloat zoomScale = (self.scrollView.zoomScale >= self.scrollView.maximumZoomScale) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale;
    
        [self zoom:pointInView zoomScale:zoomScale animated:YES];
    } else if (PGGesturesDoubleTapReset == self.doubleTapBehavior) {
        if (UIViewContentModeScaleAspectFill == self.imageContentMode) {
            self.imageContentMode = UIViewContentModeScaleAspectFit;
        } else {
            self.imageContentMode = UIViewContentModeScaleAspectFill;
        }
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.scrollView.transform = CGAffineTransformRotate(self.scrollView.transform, -self.totalRotation);
            self.totalRotation = 0.0F;
            
            [self setImage:_image forceContentMode:NO];
        }];
    }
}

- (void)showcaseZoomAndRotate:(CGFloat)animationDuration rotationRadians:(CGFloat)rotationRadians zoomScale:(CGFloat)zoomScale
{
    [UIView animateWithDuration:animationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGPoint pointInView = {self.imageView.bounds.size.width/2, self.imageView.bounds.size.height/2};
                         [self zoom:pointInView zoomScale:zoomScale * self.scrollView.zoomScale animated:NO];
                         [self rotate:rotationRadians];
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:animationDuration
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              [self rotate:-rotationRadians];
                                              CGPoint pointInView = {self.imageView.bounds.size.width/2, self.imageView.bounds.size.height/2};
                                              [self zoom:pointInView zoomScale:self.scrollView.minimumZoomScale animated:NO];
                                          }
                                          completion:nil];
                         
                     }];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(handleLongPress:)]) {
            [self.delegate handleLongPress:self];
        }
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

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self adjustContentOffset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self adjustContentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
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

@end
