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

@protocol PGGesturesViewDelegate;

typedef enum
{
    PGGesturesDoubleTapZoom,
    PGGesturesDoubleTapReset
} PGGesturesDoubleTapBehavior;

@interface PGGesturesView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGFloat minimumZoomScale;
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, assign) BOOL allowGestures;
@property (nonatomic, weak) id<PGGesturesViewDelegate> delegate;
@property (nonatomic, assign) PGGesturesDoubleTapBehavior doubleTapBehavior;

- (CGPoint)offset;
- (CGFloat)zoom;
- (CGFloat)angle;
- (void)adjustContentOffset;

- (void)showcaseZoomAndRotate:(CGFloat)animationDuration rotationRadians:(CGFloat)rotationRadians zoomScale:(CGFloat)zoomScale;

@end

@protocol PGGesturesViewDelegate <NSObject>

- (void)handleLongPress:(PGGesturesView *)gesturesView;
- (void)imageEdited:(PGGesturesView *)gesturesView;

@end
