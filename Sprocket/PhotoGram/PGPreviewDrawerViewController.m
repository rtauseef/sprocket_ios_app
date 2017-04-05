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

#import "PGPreviewDrawerViewController.h"

static NSInteger const kPGPreviewDrawerClosedDrawerHeight = 33;

@implementation PGPreviewDrawerViewController

- (IBAction)didTapDrawerButton:(id)sender {
    self.isOpened = !self.isOpened;
    
    if ([self.delegate respondsToSelector:@selector(PGPreviewDrawer:didTapButton:)]) {
        [self.delegate PGPreviewDrawer:self didTapButton:sender];
    }
}

- (BOOL)isOpened
{
    if (!_isOpened) {
        _isOpened = NO;
    }
    
    return _isOpened;
}

- (CGFloat)drawerHeight
{
    if (self.isOpened) {
        return 150;
    } else {
        return kPGPreviewDrawerClosedDrawerHeight;
    }
}

#pragma mark - Gesture Recognizers

- (IBAction)handlePan:(UIPanGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(PGPreviewDrawer:didDrag:)]) {
        [self.delegate PGPreviewDrawer:self didDrag:gesture];
    }
}

@end
