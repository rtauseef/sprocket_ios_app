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

#import "PGSocialSourceMenuCellTableViewCell.h"

#import "UIColor+Style.h"
#import "UIFont+Style.h"

@implementation PGSocialSourceMenuCellTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)configureCell:(PGSocialSource *)socialSource
{
    self.socialTitle.text = socialSource.title;
    self.socialTitle.textColor = [UIColor whiteColor];
    self.socialImageView.image = socialSource.menuIcon;
    
    UIView *selectionColorView = [[UIView alloc] init];
    selectionColorView.backgroundColor = [UIColor HPTableRowSelectionColor];
    
    self.selectedBackgroundView = selectionColorView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)signInButtonTapped:(id)sender {
    NSLog(@"Sign In Tapped");
}

@end
