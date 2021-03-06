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

#import "HPPRSelectPhotoCollectionViewCell.h"
#import "UIView+HPPRAnimation.h"
#import "HPPRCacheService.h"
#import "HPPR.h"
#import "HPPRCameraRollMedia.h"

CGFloat const kHPPRSelectPhotoCollectionViewCellOverlayAlpha = 0.75;

@interface HPPRSelectPhotoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *mediaTypeImageView; // overlay for video or live photo icon
@property (weak, nonatomic) IBOutlet UIImageView *loadingImage;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *selectionView;
@property (weak, nonatomic) IBOutlet UIImageView *checkmark;

@end

@implementation HPPRSelectPhotoCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRLoadingCellBackgroundColor];
    self.loadingImage.hidden = NO;
    self.mediaTypeImageView.hidden = YES;
    self.overlayView.alpha = 0;
    self.selectionView.hidden = !self.selectionEnabled;
}

- (void)setMedia:(HPPRMedia *)media
{
    if (media) {
        _media = media;
        self.imageView.image = nil;
        self.mediaTypeImageView.hidden = YES;
        if (media.asset) {
            if (self.retrieveLowQuality) {
                [media requestThumbnailImageWithCompletion:^(UIImage *image) {
                    [self setImage: image];
                }];
            } else {
                [media requestPreviewImageWithCompletion:^(UIImage *image) {
                    [self setImage: image];
                }];
            }
            
            return;
        }
        
        if (self.retrieveLowQuality) {
            [[HPPRCacheService sharedInstance] imageForUrl:self.media.thumbnailUrl asThumbnail:YES highPriority:NO withCompletion:^(UIImage *image, NSString *url, NSError *error) {
                if ([_media.thumbnailUrl isEqualToString:url]) {
                    [self setImage:image];
                }
            }];
        } else {
            [[HPPRCacheService sharedInstance] imageForUrl:self.media.standardUrl asThumbnail:NO highPriority:NO withCompletion:^(UIImage *image, NSString *url, NSError *error) {
                if ([_media.standardUrl isEqualToString:url]) {
                    [self setImage:image];
                }
            }];
        }
    }
}

- (void)setImage:(UIImage *)image
{
    if (image == nil) {
        if ([self.delegate respondsToSelector:@selector(selectPhotoCollectionViewCellDidFailRetrievingImage:)]) {
            [self.delegate selectPhotoCollectionViewCellDidFailRetrievingImage:self];
            self.loadingImage.hidden = YES;
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            self.loadingImage.hidden = YES;
            if (_media.mediaType == HPPRMediaTypeVideo) {
                // display overlay
                self.mediaTypeImageView.hidden = NO;
                // TODO set overlay icon
            } else {
                self.mediaTypeImageView.hidden = YES;
            }
            [self setNeedsLayout];
        });
    }
}

- (void)setSelectionEnabled:(BOOL)selectionEnabled {
    _selectionEnabled = selectionEnabled;

    self.selectionView.hidden = !self.selectionEnabled;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    self.checkmark.highlighted = selected;
}

// Fix bug with the iOS 8 SDK running on iOS 7 devices. The workaround is to add the following to your subclass of UICollectionViewCell
// http://stackoverflow.com/questions/25804588/auto-layout-in-uicollectionviewcell-not-working

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)showLoadingAnimated:(BOOL)animated
{
    if (!self.activityIndicator.isAnimating) {
        [self.activityIndicator startAnimating];
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                self.overlayView.alpha = kHPPRSelectPhotoCollectionViewCellOverlayAlpha;
            }];
        } else {
            self.overlayView.alpha = kHPPRSelectPhotoCollectionViewCellOverlayAlpha;
        }
    }
    
    self.userInteractionEnabled = NO;
}

- (void)hideLoadingAnimated:(BOOL)animated
{
    if (self.activityIndicator.isAnimating) {
        [self.activityIndicator stopAnimating];
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                self.overlayView.alpha = 0;
            }];
        } else {
            self.overlayView.alpha = 0;
        }
    }
    
    self.userInteractionEnabled = YES;
}

@end
