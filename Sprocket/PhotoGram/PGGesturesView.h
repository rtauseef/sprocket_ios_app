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

#import <HPPRMedia.h>
#import "PGEmbellishmentMetricsManager.h"

@protocol PGGesturesViewDelegate;

typedef enum
{
    PGGesturesDoubleTapZoom,
    PGGesturesDoubleTapReset
} PGGesturesDoubleTapBehavior;

@interface PGGesturesView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) HPPRMedia *media;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *editedImage;
@property (nonatomic, assign) CGFloat minimumZoomScale;
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, assign) BOOL allowGestures;
@property (nonatomic, weak) id<PGGesturesViewDelegate> delegate;
@property (nonatomic, assign) PGGesturesDoubleTapBehavior doubleTapBehavior;
@property (nonatomic, assign) CGFloat totalRotation;
@property (nonatomic, strong) PGEmbellishmentMetricsManager *embellishmentMetricManager;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *noInternetConnectionView;

@property (nonatomic, assign) BOOL isMultiSelectImage;
@property (nonatomic, assign) BOOL isSelected;

- (void)setImage:(UIImage *)image;
- (CGPoint)offset;
- (CGFloat)zoom;
- (CGFloat)angle;
- (void)adjustContentOffset;
- (void)enableGestures;
- (void)showNoInternetConnectionView;
- (void)hideNoInternetConnectionView;

@end

@protocol PGGesturesViewDelegate <NSObject>

- (void)handleLongPress:(PGGesturesView *)gesturesView;
- (void)imageEdited:(PGGesturesView *)gesturesView;

@end
