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
#import "HPPR.h"
#import "UIFont+HPPRStyle.h"
#import "UIView+HPPRAnimation.h"
#import "NSBundle+HPPRLocalizable.h"

const NSUInteger kHPPRAlbumThumbnailSize = 150;

@interface HPPRSelectAlbumTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabelView;
@property (weak, nonatomic) IBOutlet UILabel *photoCountLabelView;

@end

@implementation HPPRSelectAlbumTableViewCell

- (void) fillVideoCount: (HPPRAlbum *) album {
    if (album.videoCount > 0) {
        if (album.photoCount != 0) {
            self.photoCountLabelView.text = [NSString stringWithFormat:@"%@%@",self.photoCountLabelView.text, @"\n"];
            self.photoCountLabelView.numberOfLines = 2;
            CGRect countFrame = self.photoCountLabelView.frame;
            countFrame.size.height *= 2;
            self.photoCountLabelView.frame = countFrame;
        }
        
        if (1 == album.videoCount) {
            self.photoCountLabelView.text = [NSString stringWithFormat:@"%@%@",self.photoCountLabelView.text, HPPRLocalizedString(@"1 video", nil)];
        } else {
            self.photoCountLabelView.text = [NSString stringWithFormat:@"%@%@",self.photoCountLabelView.text, [NSString stringWithFormat:HPPRLocalizedString(@"%lu videos", @"Number of videos"), (unsigned long)album.videoCount]];
        }
    }
}

- (void)setAlbum:(HPPRAlbum *)album
{
    _album = album;
    
    [self setupColorsAndFonts];
    
    if (album.assetCollection) {
        [self setAlbumByAssetCollection:album];
        return;
    }
    
    self.albumTitleLabelView.text = album.name;
    
    if (0 == album.photoCount) {
        self.photoCountLabelView.text = @"";
    } else if (1 == album.photoCount) {
        self.photoCountLabelView.text = HPPRLocalizedString(@"1 photo", nil);
    } else {
        self.photoCountLabelView.text = [NSString stringWithFormat:HPPRLocalizedString(@"%lu photos", @"Number of photos"), (unsigned long)album.photoCount];
    }
    
    [self fillVideoCount: album];
    
    if (album.coverPhoto) {
        self.coverPhotoImageView.image = album.coverPhoto;
    } else {
        self.coverPhotoImageView.image = nil;
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSLog(@"album name: %@, provider: %@", album.name, album.provider);
            [album.provider coverPhotoForAlbum:album withRefresh:NO andCompletion:^(HPPRAlbum *album, UIImage *coverPhoto, NSError *error) {
                if (error) {
                    NSLog(@"COVER PHOTO ERROR\n%@", error);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([_album.objectID isEqualToString:album.objectID] ||
                             _album.objectID == album.objectID ) {
                            weakSelf.coverPhotoImageView.image = coverPhoto;
                            [weakSelf setNeedsLayout];
                        }
                    });
                }
            }];
        });
    }
}

- (void)setupColorsAndFonts
{
    self.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    [self.albumTitleLabelView setFont:[[HPPR sharedInstance].appearance.settings objectForKey:kHPPRPrimaryLabelFont]];
    [self.albumTitleLabelView setTextColor:[[HPPR sharedInstance].appearance.settings objectForKey:kHPPRSecondaryLabelColor]];
    [self.photoCountLabelView setFont:[[HPPR sharedInstance].appearance.settings objectForKey:kHPPRSecondaryLabelFont]];
    [self.photoCountLabelView setTextColor:[[HPPR sharedInstance].appearance.settings objectForKey:kHPPRSecondaryLabelColor]];
}

- (void)setAlbumByAssetCollection:(HPPRAlbum *)album
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:album.assetCollection options:fetchOptions];
    PHAsset *asset = [fetchResult lastObject];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    CGSize size = CGSizeMake(kHPPRAlbumThumbnailSize, kHPPRAlbumThumbnailSize);
    
    __weak __typeof(self) weakSelf = self;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        weakSelf.coverPhotoImageView.image = result;
        [weakSelf setNeedsLayout];
    }];
    
    self.albumTitleLabelView.text = album.assetCollection.localizedTitle;
    
    if (0 == album.photoCount) {
        self.photoCountLabelView.text = @"";
    } else if (1 == album.photoCount) {
        self.photoCountLabelView.text = HPPRLocalizedString(@"1 photo", nil);
    } else {
        self.photoCountLabelView.text = [NSString stringWithFormat:HPPRLocalizedString(@"%li photos", @"Number of photos"), album.photoCount];
    }
    
    [self fillVideoCount:album];
}

@end
