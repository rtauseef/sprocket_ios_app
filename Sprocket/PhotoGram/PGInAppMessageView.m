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
#import "PGInAppMessageManager.h"
#import "UIColor+Style.h"

static CGFloat const kInAppMessageViewHeight = 127.0;
static CGFloat const kInAppMessageButtonsRowHeight = 46.0;

@interface PGInAppMessageView ()

@property (nonatomic, strong) UAInAppMessage *message;
@property (nonatomic, strong) NSLayoutConstraint *bottomEdgeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *primaryButtonLeadingCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *primaryButtonLeadingLeftConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *messageIcon;

@end


@implementation PGInAppMessageView

- (instancetype)initWithMessage:(UAInAppMessage *)message
{
    self = [super init];

    if (self) {
        self.message = message;
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
                                                                        constant:10.0];

        NSLayoutConstraint *trailingEdge = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.superview
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1.0
                                                                         constant:-10.0];

        self.bottomEdgeConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.superview
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:[self viewHeight]];

        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:[self viewHeight]];

        [NSLayoutConstraint activateConstraints:@[leadingEdge, trailingEdge, self.bottomEdgeConstraint, height]];
    }
}

- (void)show
{
    self.bottomEdgeConstraint.constant = 0;
}

- (void)hide
{
    self.bottomEdgeConstraint.constant = [self viewHeight];
}


#pragma mark - Private

- (CGFloat)viewHeight
{
    CGFloat height = kInAppMessageViewHeight;

    UANotificationCategory *buttonCategory = self.message.buttonCategory;

    if (buttonCategory == nil || buttonCategory.actions.count == 0) {
        height -= kInAppMessageButtonsRowHeight;
    }

    return height;
}

- (void)setMessage:(UAInAppMessage *)message
{
    _message = message;

    [self setupView];
}

- (void)setupView
{
    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6.0;

    self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:self.message.alert
                                                                       attributes:@{
                                                                                    NSFontAttributeName: self.messageLabel.font,
                                                                                    NSForegroundColorAttributeName: [UIColor HPRowColor],
                                                                                    NSParagraphStyleAttributeName: paragraphStyle
                                                                                    }];

    self.primaryButton.layer.cornerRadius = 2.0;
    self.secondaryButton.layer.cornerRadius = 2.0;
    self.secondaryButton.layer.borderWidth = 1.0;
    self.secondaryButton.layer.borderColor = [UIColor HPTabBarUnselectedColor].CGColor;

    UANotificationCategory *buttonCategory = self.message.buttonCategory;

    if (buttonCategory == nil || buttonCategory.actions.count == 0) {
        self.primaryButton.hidden = YES;
        self.secondaryButton.hidden = YES;

    } else {
        NSString *primaryButtonLabel = [[buttonCategory.actions firstObject] title];
        NSString *secondaryButtonLabel = [[buttonCategory.actions lastObject] title];

        NSString *messageType = [self.message.extra objectForKey:kInAppMessageTypeKey];
        if ([messageType isEqualToString:kInAppMessageTypeValueBuyPaper]) {
            primaryButtonLabel = NSLocalizedString(@"Get More", nil);
            self.messageIcon.image = [UIImage imageNamed:@"ZincPhotoPaper"];

        } else if ([messageType isEqualToString:kInAppMessageTypeValueFirmwareUpgrade]) {
            primaryButtonLabel = NSLocalizedString(@"Get Firmware Upgrade", nil);
            self.messageIcon.image = [UIImage imageNamed:@"FW_icon"];
        }

        [self.primaryButton setTitle:primaryButtonLabel forState:UIControlStateNormal];

        if (buttonCategory.actions.count == 1) {
            self.secondaryButton.hidden = YES;

            self.primaryButtonLeadingCenterConstraint.active = NO;
            self.primaryButtonLeadingLeftConstraint.active = YES;

        } else {
            [self.secondaryButton setTitle:secondaryButtonLabel forState:UIControlStateNormal];
        }
    }
}

@end
