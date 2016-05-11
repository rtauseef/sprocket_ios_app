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

#import "HPPRAlertStripView.h"
#import "UIColor+HPPRStyle.h"
#import "UIFont+HPPRStyle.h"
#import "UIView+HPPRAnimation.h"
#import "NSBundle+HPPRLocalizable.h"

@interface HPPRAlertStripView()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) CALayer *borderLayer;

@end

@implementation HPPRAlertStripView

NSString * const kDefaultMessageText = @"Message text";
NSString * const kDefaultActionText = @"Action";

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.messageText = kDefaultMessageText;
        self.actionText = kDefaultActionText;
        [self.button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addBorder];
        [self addShadow];
        self.accessibilityIdentifier = @"Alert Strip";
        self.label.accessibilityIdentifier = @"Alert Strip Message Label";
        self.button.accessibilityIdentifier = @"Alert Strip Action Button";
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    if (self.borderLayer) {
        self.borderLayer.frame = CGRectMake(0, 0, self.frame.size.width, 1);
    }
}

#pragma mark - Property setters

- (void)setMessageText:(NSString *)messageText
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont HPPRSimplifiedLightFontWithSize:16.0f],
                                 NSForegroundColorAttributeName:[UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0]
                                 };
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:messageText attributes:attributes];
    self.label.attributedText = text;
}

- (void)setActionText:(NSString *)actionText
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont HPPRSimplifiedLightFontWithSize:16.0f],
                                 NSForegroundColorAttributeName:[UIColor HPPRBlueColor]
                                 };
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:actionText attributes:attributes];
    [self.button setAttributedTitle:text forState:UIControlStateNormal];
}

#pragma mark - Button handler

- (void)buttonTapped:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionButtonTapped:)]) {
        [self.delegate actionButtonTapped:self];
    }
}

#pragma mark - Border

- (void)addBorder
{
    self.borderLayer = [CALayer layer];
    self.borderLayer.frame = CGRectMake(0, 0, self.frame.size.width, 1);
    self.borderLayer.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [self.layer addSublayer:self.borderLayer];
}

- (void)addShadow
{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.1f;
    self.layer.shadowOffset = CGSizeMake(0.0f, -1.0f);
    self.layer.masksToBounds = NO;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

@end
