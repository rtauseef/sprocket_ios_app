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

#import "UITableView+Header.h"
#import "UIFont+Style.h"
#import "UIColor+HexString.h"

#define TITLE_LEFT_OFFSET 10.0f
#define TITLE_HEIGHT 30.0f

@implementation UITableView (Header)

- (UIView *)headerViewForSupportSection
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, HEADER_HEIGHT)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_LEFT_OFFSET, HEADER_HEIGHT - TITLE_HEIGHT, self.frame.size.width, TITLE_HEIGHT)];
    titleLabel.text = NSLocalizedString(@"SUPPORT:", @"Title of a table view header");
    titleLabel.textColor = [UIColor colorWithHexString:@"8F8F95"];
    titleLabel.font = [UIFont HPSimplifiedLightFontWithSize:18.0f];
    
    [headerView addSubview:titleLabel];
    
    return headerView;
}

@end
