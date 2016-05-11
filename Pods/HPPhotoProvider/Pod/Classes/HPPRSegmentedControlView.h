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
#import "HPPRView.h"

@protocol HPPRSegmentedControlViewDelegate;

@interface HPPRSegmentedControlView : HPPRView

@property (nonatomic, weak) id<HPPRSegmentedControlViewDelegate> delegate;

@property(nonatomic) NSInteger selectedSegmentIndex;
@property(nonatomic) BOOL workAsToggleSwitch;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment state:(UIControlState)state;
- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment state:(UIControlState)state;
- (void)setMaskedImageUrl:(NSString *)url forSegmentAtIndex:(NSUInteger)segment state:(UIControlState)state;

@end


@protocol HPPRSegmentedControlViewDelegate <NSObject>

- (void)segmentedControlViewDidChange:(HPPRSegmentedControlView *)segmentedControlView;

@end