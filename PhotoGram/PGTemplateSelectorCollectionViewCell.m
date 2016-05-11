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

#import "PGTemplateSelectorCollectionViewCell.h"
#import "UIFont+Style.h"
#import "UIColor+Style.h"

@implementation PGTemplateSelectorCollectionViewCell

- (void)awakeFromNib
{
	[super awakeFromNib];
    self.templateTitle.font = [UIFont HPSimplifiedLightFontWithSize:11.0f];
    self.selectedView.layer.borderColor = [UIColor colorWithRed:0.0f green:150.0f/255.0f blue:214.0f/255.0f alpha:1.0f].CGColor;
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	self.templateTitle.text = @"";
    self.templateImageView.image = nil;
}

@end
