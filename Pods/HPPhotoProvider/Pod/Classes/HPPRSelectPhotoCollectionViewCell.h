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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HPPRMedia.h"

@protocol HPPRSelectPhotoCollectionViewCellDelegate;

@interface HPPRSelectPhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) HPPRMedia *media;
@property (assign, nonatomic) BOOL retrieveLowQuality;
@property (weak, nonatomic) id<HPPRSelectPhotoCollectionViewCellDelegate> delegate;
@property (assign, nonatomic) BOOL selectionEnabled;

- (void)showLoadingAnimated:(BOOL)animated;
- (void)hideLoadingAnimated:(BOOL)animated;

@end

@protocol HPPRSelectPhotoCollectionViewCellDelegate <NSObject>

- (void)selectPhotoCollectionViewCellDidFailRetrievingImage:(HPPRSelectPhotoCollectionViewCell *)cell;

@end
