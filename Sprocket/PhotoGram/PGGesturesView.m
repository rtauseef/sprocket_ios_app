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
#import "UIImage+ImageResize.h"
#import "UIView+Background.h"

static CGFloat const kMinimumZoomScale = 1.0f;
static CGFloat const kAnimationDuration = 0.3f;
static CGFloat const kMarginOfError = .01f;
static CGFloat const kMarginOfSquare = 2.0f;

@interface PGGesturesView ()

@property (nonatomic, assign) UIViewContentMode imageContentMode;
@property (nonatomic, strong) NSTimer *zoomTimer;

@property (weak, nonatomic) IBOutlet UIView *selectionOverlayView;
@property (weak, nonatomic) IBOutlet UIImageView *checkmark;
@property (weak, nonatomic) IBOutlet UILabel *noConnectionViewTitle;
@property (weak, nonatomic) IBOutlet UILabel *noConnectionViewDescription;

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
    UIView *xibView = [[[NSBundle mainBundle] loadNibNamed:@"PGGesturesView"
                                                     owner:self
                                                   options:nil] objectAtIndex:0];
    xibView.frame = self.bounds;
    xibView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:xibView];
    
    self.noConnectionViewTitle.text = NSLocalizedString(@"No Connection Available", nil);
    self.noConnectionViewDescription.text = NSLocalizedString(@"Please connect to a data source.\nYou can also use your device photos.", nil);
    
    self.accessibilityIdentifier = @"GestureView";
    self.scrollView.accessibilityIdentifier = @"GestureScrollView";
    self.imageView.accessibilityIdentifier = @"GestureImageView";
    
    self.imageContentMode = UIViewContentModeScaleAspectFill;
    
    self.doubleTapBehavior = PGGesturesDoubleTapReset;
    self.totalRotation = 0.0F;
    
    self.isSelected = YES;
    self.isMultiSelectImage = NO;
    
    self.embellishmentMetricManager = [[PGEmbellishmentMetricsManager alloc] init];

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
    
    self.selectionOverlayView.hidden = isSelected;
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
    _image = image;
    _editedImage = image;
    
    if (fabs(image.size.width - image.size.height) < kMarginOfSquare) {
        self.imageContentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.imageContentMode = UIViewContentModeScaleAspectFill;
    }
    self.imageView.contentMode = self.imageContentMode;
    self.scrollView.contentMode = self.imageContentMode;

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

- (UIImage *)initialImage
{
    UIImage *initialImage = self.image;
    CGImageRef imgRef = initialImage.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    if (width > height) {
        // Rotate image

        CGFloat centerX = initialImage.size.width/2;
        CGFloat centerY = initialImage.size.height/2;
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(centerX, centerY);
        transform = CGAffineTransformRotate(transform, M_PI/2);
        transform = CGAffineTransformTranslate(transform, -centerY, -centerX);
        
        UIGraphicsBeginImageContext(CGSizeMake(height, width));
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextConcatCTM(context, transform);
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
        initialImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        imgRef = initialImage.CGImage;
        width = CGImageGetWidth(imgRef);
        height = CGImageGetHeight(imgRef);
    }
    
    if (self.imageContentMode == UIViewContentModeScaleAspectFill) {
        // Scale image to fill scroll view size
        
        CGRect scaleRect = CGRectZero;
        CGFloat newHeight = self.scrollView.bounds.size.height;
        CGFloat newWidth = (width/height) * newHeight;
        scaleRect.size = CGSizeMake(newWidth, newHeight);
        
        UIGraphicsBeginImageContext(scaleRect.size);
        [self.image drawInRect:scaleRect];
        initialImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        // Scale image to fit some scroll view dimension
        CGRect scaleRect = CGRectZero;

        CGFloat scrollViewRatio = self.scrollView.bounds.size.width / self.scrollView.bounds.size.height;
        CGFloat imageRatio = width / height;
        CGFloat newWidth, newHeight;
        if (imageRatio > scrollViewRatio) {
            newWidth = self.scrollView.bounds.size.width;
            newHeight = (height/width) * newWidth;
            scaleRect.origin.y = self.scrollView.bounds.size.height/2 - newHeight/2;
        } else {
            newHeight = self.scrollView.bounds.size.height;
            newWidth = (width/height) * newHeight;
            scaleRect.origin.x = self.scrollView.bounds.size.width/2 - newWidth/2;
        }
        scaleRect.size = CGSizeMake(newWidth, newHeight);
        
        UIGraphicsBeginImageContext(self.scrollView.bounds.size);
        [self.image drawInRect:scaleRect];
        initialImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    return initialImage;
}

- (UIImage *)applyTransformToImage:(UIImage *)image
{
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGFloat centerX = image.size.width/2;
    CGFloat centerY = image.size.height/2;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(centerX, centerY);
    transform = CGAffineTransformRotate(transform, self.totalRotation);
    transform = CGAffineTransformScale(transform, self.scrollView.zoomScale, self.scrollView.zoomScale);
    
    CGFloat centerOffsetX = self.imageView.frame.size.width/2 - self.scrollView.bounds.size.width/2;
    CGFloat centerOffsetY = self.imageView.frame.size.height/2 - self.scrollView.bounds.size.height/2;
    CGFloat offsetX = (centerOffsetX - self.scrollView.contentOffset.x) / self.scrollView.zoomScale;
    CGFloat offsetY = (centerOffsetY - self.scrollView.contentOffset.y) / self.scrollView.zoomScale;
    transform = CGAffineTransformTranslate(transform, offsetX, offsetY);
    transform = CGAffineTransformTranslate(transform, -centerX, -centerY);
    
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextConcatCTM(context, transform);
    
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (UIImage *)captureEditedImage
{
    if (!self.image) {
        return nil;
    }
    
    UIImage *initialImage = [self initialImage];
    UIImage *transformedImage = [self applyTransformToImage:initialImage];
    
    CGRect cropRect = CGRectMake(0, 0, initialImage.size.width, initialImage.size.height);
    if (initialImage.size.height >= initialImage.size.width) {
        cropRect.origin.x += (initialImage.size.width-self.scrollView.bounds.size.width)/2;
        cropRect.size.width -= initialImage.size.width-self.scrollView.bounds.size.width;
    } else {
        cropRect.origin.y += (initialImage.size.height-self.scrollView.bounds.size.height)/2;
        cropRect.size.width -= initialImage.size.height-self.scrollView.bounds.size.height;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(transformedImage.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:1 orientation:transformedImage.imageOrientation];
    
    CGRect finalRect = CGRectMake(0, 0, croppedImage.size.width, croppedImage.size.height);
    UIGraphicsBeginImageContext(croppedImage.size);
    
    [[UIColor whiteColor] setFill];
    [[UIBezierPath bezierPathWithRect:finalRect] fill];
    
    [croppedImage drawInRect:finalRect blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *resultImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (void)zoomTimer:(NSTimer *)timer
{
    self.editedImage = [self captureEditedImage];
    [self.zoomTimer invalidate];
    self.zoomTimer = nil;
}

- (void)showNoInternetConnectionView
{
    self.noInternetConnectionView.hidden = NO;
}

- (void)hideNoInternetConnectionView
{
    self.noInternetConnectionView.hidden = YES;
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
        self.editedImage = [self captureEditedImage];
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
        self.editedImage = [self captureEditedImage];
        self.scrollView.zoomScale = kMinimumZoomScale;
    }];
    
    self.editedImage = [self captureEditedImage];
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
    self.editedImage = [self captureEditedImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.editedImage = [self captureEditedImage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.editedImage = [self captureEditedImage];
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
