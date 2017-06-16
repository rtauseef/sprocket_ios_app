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

#import "PGAttributedLabel.h"

@implementation PGAttributedLabel

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:self.fontFamily size:self.fontSize]
                             range:NSMakeRange(0, attributedString.length)];
    self.attributedText = attributedString;
}

// These two overrides are intended to fix storyboard design-time crashes
// Adapted from https://stackoverflow.com/questions/28204108/ib-designables-failed-to-update-auto-layout-status-failed-to-load-designables
- (instancetype)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

@end
