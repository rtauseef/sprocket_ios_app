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

#import "PGTilingOverlayTile.h"

@interface PGTilingOverlayTile ()

@property (weak, nonatomic) IBOutlet UIView *mask;
@property (weak, nonatomic) IBOutlet UIButton *checkbox;

@end

@implementation PGTilingOverlayTile

- (BOOL)isChecked {
    return self.checkbox.isSelected;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self) {
        return nil;
    }
    
    return result;
}

- (IBAction)checkboxTapped:(UIButton *)sender
{
    sender.selected = !sender.selected;
    CGFloat maskAlpha = sender.selected ? 0.0 : 0.6;
    self.mask.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:maskAlpha];
}

@end
