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

@interface HPPRSelectPhotoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation HPPRSelectPhotoCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageView.backgroundColor = [UIColor colorWithRed:0xDB/255.0f  green:0xEA/255.0f  blue:0xF8/255.0f alpha:1.0f];
}

- (void)setMedia:(HPPRMedia *)media
{
    if (media) {
        _media = media;
        self.imageView.image = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^ {
            if (self.retrieveLowQuality) {
                [[HPPRCacheService sharedInstance] imageForUrl:self.media.thumbnailUrl asThumbnail:YES withCompletion:^(UIImage *image, NSString *url, NSError *error) {
                    if ([_media.thumbnailUrl isEqualToString:url]) {
                        [self setImage:image];
                    }
                }];
            } else {
                [[HPPRCacheService sharedInstance] imageForUrl:self.media.standardUrl asThumbnail:NO withCompletion:^(UIImage *image, NSString *url, NSError *error) {
                    if ([_media.standardUrl isEqualToString:url]) {
                        [self setImage:image];
                    }
                }];
            }
        });
    }
}

- (void)setImage:(UIImage *)image
{
    if (image == nil) {
        if ([self.delegate respondsToSelector:@selector(selectPhotoCollectionViewCellDidFailRetrievingImage:)]) {
            [self.delegate selectPhotoCollectionViewCellDidFailRetrievingImage:self];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^ {
            self.imageView.image = image;
            [self setNeedsLayout];
        });
    }
}

// Fix bug with the iOS 8 SDK running on iOS 7 devices. The workaround is to add the following to your subclass of UICollectionViewCell
// http://stackoverflow.com/questions/25804588/auto-layout-in-uicollectionviewcell-not-working

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

@end
