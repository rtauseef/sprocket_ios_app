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

#import "PGInAppMessageView.h"

static CGFloat const kInAppMessageViewHeight = 127.0;

@interface PGInAppMessageView ()

@property (nonatomic, strong) UAInAppMessage *message;
@property (nonatomic, strong) NSLayoutConstraint *bottomEdgeConstraint;

@end


@implementation PGInAppMessageView

- (instancetype)initWithMessage:(UAInAppMessage *)message
{
    self = [super init];

    if (self) {
        self.message = message;
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return self;
}

- (void)setupConstraints
{
    if (self.superview) {
        NSLayoutConstraint *leadingEdge = [NSLayoutConstraint constraintWithItem:self
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.superview
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1.0
                                                                        constant:0.0];

        NSLayoutConstraint *trailingEdge = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.superview
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1.0
                                                                         constant:0.0];

        self.bottomEdgeConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.superview
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:kInAppMessageViewHeight];

        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:kInAppMessageViewHeight];

        [NSLayoutConstraint activateConstraints:@[leadingEdge, trailingEdge, self.bottomEdgeConstraint, height]];
    }
}

- (void)show
{
    self.bottomEdgeConstraint.constant = 0;
}

- (void)hide
{
    self.bottomEdgeConstraint.constant = kInAppMessageViewHeight;
}

@end
