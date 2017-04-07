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
static NSInteger const kPGPreviewDrawerHotAreaHeight = 50;

@interface PGPreviewDrawerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation PGPreviewDrawerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.button.clipsToBounds = NO;
    self.button.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.button.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.button.layer.shadowOpacity = 0.8f;
    self.button.layer.shadowRadius = 6.0f;
}

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
        return [self drawerHeightOpened];
    } else {
        return [self drawerHeightClosed];
    }
}

- (CGFloat)drawerHeightOpened
{
    return 150 + kPGPreviewDrawerHotAreaHeight;
}

- (CGFloat)drawerHeightClosed
{
    return kPGPreviewDrawerClosedDrawerHeight + kPGPreviewDrawerHotAreaHeight;
}

#pragma mark - Gesture Recognizers

- (IBAction)handlePan:(UIPanGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(PGPreviewDrawer:didDrag:)]) {
        [self.delegate PGPreviewDrawer:self didDrag:gesture];
    }
}

@end
