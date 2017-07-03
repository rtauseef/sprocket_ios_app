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

#import <UIKit/UIKit.h>

@protocol PGPreviewDrawerViewControllerDelegate;

typedef NS_ENUM(NSInteger, PGPreviewDrawerTiling) {
    PGPreviewDrawerTilingSingle,
    PGPreviewDrawerTiling2x2,
    PGPreviewDrawerTiling3x3
};

@interface PGPreviewDrawerViewController : UIViewController

@property (nonatomic, weak) id<PGPreviewDrawerViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isOpened;
@property (nonatomic, assign) BOOL isPeeking;
@property (nonatomic, assign) BOOL showCopies;
@property (nonatomic, assign) BOOL showTiling;
@property (nonatomic, assign) BOOL showPrintQueue;
@property (nonatomic, assign) BOOL alwaysShowPrintQueue;
@property (assign, nonatomic) NSInteger numberOfCopies;
@property (assign, nonatomic) PGPreviewDrawerTiling tilingOption;

- (CGFloat)drawerHeight;
- (CGFloat)drawerHeightOpened;
- (CGFloat)drawerHeightPeeking;
- (CGFloat)drawerHeightClosed;
- (void)configureShowPrintQueue;

@end

@protocol PGPreviewDrawerViewControllerDelegate <NSObject>

- (void)pgPreviewDrawer:(PGPreviewDrawerViewController *)drawer didTapButton:(UIButton *)button;
- (void)pgPreviewDrawer:(PGPreviewDrawerViewController *)drawer didDrag:(UIPanGestureRecognizer *)gesture;
- (void)pgPreviewDrawer:(PGPreviewDrawerViewController *)drawer didChangeTillingOption:(PGPreviewDrawerTiling)tilingOption;
- (void)pgPreviewDrawerDidTapPrintQueue:(PGPreviewDrawerViewController *)drawer;
- (void)pgPreviewDrawerDidClearQueue:(PGPreviewDrawerViewController *)drawer;

@end
