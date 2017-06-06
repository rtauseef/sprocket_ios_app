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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HPPRSelectPhotoProvider.h"

typedef NS_ENUM(NSUInteger, HPPRSelectPhotoCollectionViewMode) {
    HPPRSelectPhotoCollectionViewModeGrid,
    HPPRSelectPhotoCollectionViewModeList
};

@protocol HPPRSelectPhotoCollectionViewControllerDelegate;

@interface HPPRSelectPhotoCollectionViewController : UIViewController

@property (strong, nonatomic) HPPRSelectPhotoProvider *provider;
@property (nonatomic, weak) id<HPPRSelectPhotoCollectionViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *customNoPhotosMessage;
@property (assign, nonatomic) BOOL allowMultiSelect;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)refresh;
- (void)beginMultiSelect;
- (void)endMultiSelect:(BOOL)refresh;
- (BOOL)isInMultiSelectMode;

@end

@protocol HPPRSelectPhotoCollectionViewControllerDelegate <NSObject>

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didSelectImage:(UIImage *)image source:(NSString *)source media:(HPPRMedia *)media;

@optional

- (UIEdgeInsets)collectionViewContentInset;
- (AVCaptureDevicePosition)cameraPosition;
- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didChangeViewMode:(HPPRSelectPhotoCollectionViewMode)viewMode;
- (void)selectPhotoCollectionViewControllerDidInitiateMultiSelectMode:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController;
- (void)selectPhotoCollectionViewControllerDidSelectCamera:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController;
- (BOOL)selectPhotoCollectionViewControllerShouldRequestOnlyLowResolutionImage:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController;

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didAddMediaToSelection:(HPPRMedia *)media;
- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didRemoveMediaFromSelection:(HPPRMedia *)media;
- (BOOL)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController shouldAddMediaToSelection:(HPPRMedia *)media;
- (BOOL)selectPhotoCollectionViewControllerShouldAllowAdditionalMediaSelection:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController;

@end

