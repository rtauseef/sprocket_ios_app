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
#import "PGSVGMetadataLoader.h"
#import "MPPaper.h"

@protocol PGSVGLoaderDelegate;

@interface PGSVGLoader : NSObject

@property (strong, nonatomic) UIView *shadowedSvgImageView;
@property (strong, nonatomic) UIView *svgImageView; // View with the image view got from the SVG file and the picBox and text fields
@property (strong, nonatomic) NSString *source;
@property (assign, nonatomic) CGFloat transformScaleValue;
@property (weak, nonatomic) id<PGSVGLoaderDelegate> delegate;
@property (assign, nonatomic) UITextView *descriptionTextView;
@property (strong, nonatomic) NSString *customUserText;
@property (strong, nonatomic) NSString *textPrompt;
@property (assign, nonatomic) BOOL pageIsActive;
@property (strong, nonatomic) NSString *locationName;

- (void)setPhoto:(UIImage *)photo media:(HPPRMedia *)media containerView:(UIView *)containerView delegate:(id<PGSVGLoaderDelegate>)delegate;

- (void)loadFile:(NSString *)fileName path:(NSString *)path reloadGestureImageView:(BOOL)reloadGestureImageView withCompletion:(void (^)(void))completion;
- (void)loadFileForPaperSize:(MPPaperSize)paperSize reloadGestureImageView:(BOOL)reloadGestureImageView withCompletion:(void (^)(void))completion;

- (void)showTextBorder:(BOOL)show;
- (void)showTextWarning:(BOOL)show;
- (void)showTextPrompt:(BOOL)show;

- (void)forceEditing:(NSRange)selectedRange;
- (UIImage *)screenshotImage;

- (CGPoint)offset;
- (CGFloat)zoom;
- (CGFloat)angle;

- (void)showcaseZoomAndRotate:(CGFloat)animationDuration rotationRadians:(CGFloat)rotationRadians zoomScale:(CGFloat)zoomScale;

@end


@protocol PGSVGLoaderDelegate <NSObject>

@optional

- (void)svgLoaderDidLoadSVGImageView:(PGSVGLoader *)svgLoader;
- (void)svgLoader:(PGSVGLoader *)svgLoader textViewDidBeginEditing:(UITextView *)textView;
- (void)svgLoader:(PGSVGLoader *)svgLoader textViewDidChange:(UITextView *)textView;
- (void)svgLoaderDidLongPress:(PGSVGLoader *)svgLoader;

@end