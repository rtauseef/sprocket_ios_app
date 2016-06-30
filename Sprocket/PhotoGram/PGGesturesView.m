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
#import "PGAnalyticsManager.h"
#import "UIImage+imageResize.h"
#import <Crashlytics/Crashlytics.h>

CGFloat const kMinimumZoomScale = 1.0f;
CGFloat const kMaximumZoomScale = 4.0f;
CGFloat const kMinimumPressDurationInSeconds = 0.35f;

@interface PGGesturesView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CGFloat totalRotation;
@property (nonatomic, assign) UIViewContentMode imageContentMode;

@end

@implementation PGGesturesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
        
        self.doubleTapBehavior = PGGesturesDoubleTapZoom;
        self.totalRotation = 0.0F;
        
        [self addSubview:self.scrollView];
        
        self.clipsToBounds = YES;
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired = 1;
        [self.scrollView addGestureRecognizer:doubleTapGesture];
        
        UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGestureRecognized:)];
        rotateGesture.delegate = self;
        [self.scrollView addGestureRecognizer:rotateGesture];
        
        // attach long press gesture to collectionView
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
        lpgr.minimumPressDuration = kMinimumPressDurationInSeconds;
        lpgr.delaysTouchesBegan = YES;
        lpgr.delegate = self;
        [self.scrollView addGestureRecognizer:lpgr];
    }
    
    return self;
}

#pragma mark - Getter & Setters

- (void)setAllowGestures:(BOOL)allowGestures
{
    _allowGestures = allowGestures;
    
    if (!allowGestures) {
        self.scrollView.scrollEnabled = NO;
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

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.accessibilityIdentifier = @"GestureImageView";
        self.imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:self.imageView];
    }
    
    CGFloat scaleFactor = self.frame.size.width / image.size.width;
    
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleFactor, scaleFactor);
    self.imageView.transform = transform;
    
    self.imageView.image = image;
    self.imageView.contentMode = self.imageContentMode;
    
    CGSize imageFinalSize = [image imageFinalSizeAfterContentModeApplied:self.imageView.contentMode containerSize:self.scrollView.bounds.size];
    self.imageView.frame = CGRectMake(0, 0, imageFinalSize.width, imageFinalSize.height);
    
    self.scrollView.minimumZoomScale = scaleFactor * self.minimumZoomScale;
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(self.imageView.frame), CGRectGetMaxY(self.imageView.frame));
    self.scrollView.contentOffset = CGPointMake((imageFinalSize.width - self.scrollView.bounds.size.width) / 2,
                                                (imageFinalSize.height - self.scrollView.bounds.size.height) / 2);
}

#pragma mark - Helpers

- (void)rotate:(CGFloat)radians
{
    self.totalRotation += radians;
    
    self.scrollView.transform = CGAffineTransformRotate(self.scrollView.transform, radians);
    float angle = atan2(self.scrollView.transform.b, self.scrollView.transform.a) * 180.0f / M_PI;
    NSString *angleValue = [NSString stringWithFormat:@"%.1f°", angle];
    [Crashlytics setObjectValue:angleValue forKey:@"Rotation"];
    if ([PGAnalyticsManager sharedManager].trackPhotoPosition) {
        [PGAnalyticsManager sharedManager].photoRotationEdited = YES;
    }
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
    if ( !(self.imageView.frame.size.width > self.scrollView.bounds.size.width+.01F) &&
        !(self.imageView.frame.size.height > self.scrollView.bounds.size.height+.01F)) {
        [UIView animateWithDuration:0.3F animations:^{
            self.scrollView.contentOffset = CGPointMake((self.imageView.frame.size.width - self.scrollView.bounds.size.width) / 2,
                                                        (self.imageView.frame.size.height - self.scrollView.bounds.size.height) / 2);
        }];
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
        
        [UIView animateWithDuration:0.3F animations:^{
            self.scrollView.transform = CGAffineTransformRotate(self.scrollView.transform, -self.totalRotation);
            self.totalRotation = 0.0F;
            
            [self setImage:_image];
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

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self adjustContentOffset];
    
    [Crashlytics setObjectValue:[NSString stringWithFormat:@"%.1f", scale] forKey:@"Scale"];
    if ([PGAnalyticsManager sharedManager].trackPhotoPosition) {
        [PGAnalyticsManager sharedManager].photoZoomEdited = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self adjustContentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [Crashlytics setObjectValue:[NSString stringWithFormat:@"%.1f, %.1f", self.scrollView.contentOffset.x, self.scrollView.contentOffset.y] forKey:@"Offset"];
    if ([PGAnalyticsManager sharedManager].trackPhotoPosition) {
        [PGAnalyticsManager sharedManager].photoPanEdited = YES;
    }
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
