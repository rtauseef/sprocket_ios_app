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

#import "HPPRFacebookPhotoProvider.h"
#import "HPPRSelectAlbumTableViewCell.h"
#import "HPPRCacheService.h"
#import "UIFont+HPPRStyle.h"
#import "UIView+HPPRAnimation.h"
#import "NSBundle+HPPRLocalizable.h"

@interface HPPRSelectAlbumTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabelView;
@property (weak, nonatomic) IBOutlet UILabel *photoCountLabelView;

@end

@implementation HPPRSelectAlbumTableViewCell

- (void)setAlbum:(HPPRAlbum *)album
{
    _album = album;
    
    [self.albumTitleLabelView setFont:[UIFont HPPRSimplifiedRegularFontWithSize:17.0f]];
    [self.photoCountLabelView setFont:[UIFont HPPRSimplifiedLightFontWithSize:12.0f]];
    
    self.albumTitleLabelView.text = album.name;
    
    if (1 == album.photoCount) {
        self.photoCountLabelView.text = HPPRLocalizedString(@"1 photo", nil);
    } else {
        self.photoCountLabelView.text = [NSString stringWithFormat:HPPRLocalizedString(@"%lu photos", @"Number of photos"), (unsigned long)album.photoCount];
    }
    
    if (album.coverPhoto) {
        self.coverPhotoImageView.image = album.coverPhoto;
    } else {
        self.coverPhotoImageView.image = nil;
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [album.provider coverPhotoForAlbum:album withRefresh:NO andCompletion:^(HPPRAlbum *album, UIImage *coverPhoto, NSError *error) {
                if (error) {
                    NSLog(@"COVER PHOTO ERROR\n%@", error);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([_album.objectID isEqualToString:album.objectID]) {
                            weakSelf.coverPhotoImageView.image = coverPhoto;
                            [weakSelf setNeedsLayout];
                        }
                    });
                }
            }];
        });
    }
}

@end
