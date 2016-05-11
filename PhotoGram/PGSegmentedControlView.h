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
#import "PGView.h"

@protocol PGSegmentedControlViewDelegate;

@interface PGSegmentedControlView : PGView

@property (nonatomic, weak) id<PGSegmentedControlViewDelegate> delegate;

@property(nonatomic) NSInteger selectedSegmentIndex;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment state:(UIControlState)state;
- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment state:(UIControlState)state;
- (void)setMaskedImageUrl:(NSString *)url forSegmentAtIndex:(NSUInteger)segment state:(UIControlState)state;

@end


@protocol PGSegmentedControlViewDelegate <NSObject>

- (void)segmentedControlViewDidChange:(PGSegmentedControlView *)segmentedControlView;

@end