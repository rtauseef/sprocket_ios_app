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

#import "PGSideBarMenuTableViewCell.h"
#import "PGAppNavigation.h"
#import "UIColor+Style.h"
#import "PGLinkSettings.h"
#import "PGInboxMessageManager.h"

#import <MP.h>
#import <MPBTPrintManager.h>

NSInteger const kPGSideBarMenuItemsNumberOfRows = 8;

CGFloat const kPGSideBarMenuItemsRegularCellHeight = 52.0f;
CGFloat const kPGSideBarMenuItemsSmallCellHeight = 38.0f;

CGFloat const kPGSideBarMenuItemsSmallFontSize = 16.0f;

@interface PGSideBarMenuTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titlePadding;

@end

@implementation PGSideBarMenuTableViewCell

- (void)configureCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.backgroundColor = [UIColor clearColor];
    self.menuTitle.textColor = [UIColor whiteColor];
    
    UIView *selectionColorView = [[UIView alloc] init];
    selectionColorView.backgroundColor = [UIColor HPTableRowSelectionColor];
    
    self.selectedBackgroundView = selectionColorView;
    
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        self.menuTitle.font = [UIFont fontWithName:self.menuTitle.font.fontName size:kPGSideBarMenuItemsSmallFontSize];
    }
    
    switch (indexPath.row) {
        case PGSideBarMenuCellSprocket:
            self.menuTitle.text = NSLocalizedString(@"sprocket", nil);
            self.menuImageView.image = [UIImage imageNamed:@"menuSprocket"];
            break;
        case PGSideBarMenuCellInbox:
            self.menuTitle.text = NSLocalizedString(@"Inbox", nil);
            self.menuImageView.image = [self inboxImage];
            self.titlePadding.constant = 14;
            break;
        case PGSideBarMenuCellPrintQueue:
            self.menuTitle.text = NSLocalizedString(@"Print Queue", nil);
            self.menuImageView.image = [self printQueueImage];
            self.titlePadding.constant = 11;
            break;
        case PGSideBarMenuCellBuyPaper:
            self.menuTitle.text = NSLocalizedString(@"Buy Paper", nil);
            self.menuImageView.image = [UIImage imageNamed:@"menuBuyPaper"];
            break;
        case PGSideBarMenuCellHowToAndHelp:
            self.menuTitle.text = NSLocalizedString(@"How to & Help", nil);
            self.menuImageView.image = [UIImage imageNamed:@"menuHowToHelp"];
            break;
        case PGSideBarMenuCellTakeSurvey:
            self.menuTitle.text = NSLocalizedString(@"Take Survey", nil);
            self.menuImageView.image = [UIImage imageNamed:@"menuTakeSurvey"];
            break;
        case PGSideBarMenuCellPrivacy:
            self.menuTitle.text = NSLocalizedString(@"Privacy", nil);
            self.menuImageView.image = [UIImage imageNamed:@"menuPrivacy"];
            break;
        case PGSideBarMenuCellAbout:
            self.menuTitle.text = NSLocalizedString(@"About", nil);
            self.menuImageView.image = [UIImage imageNamed:@"menuAbout"];
            break;
        /*case PGSideBarMenuCellLinkReader:
            self.menuTitle.text = NSLocalizedString(@"Scan", nil);
            self.menuImageView.image = [UIImage imageNamed:@"menuAbout  "];
            break;*/
        default:
            break;
    }
}

- (UIImage *)inboxImage
{
    if ([[PGInboxMessageManager sharedInstance] hasUnreadMessages]) {
        return [UIImage imageNamed:@"Inbox_Active"];
    }

    return [UIImage imageNamed:@"Inbox_Inactive"];
}

- (UIImage *)printQueueImage
{
    if ([MPBTPrintManager sharedInstance].status != MPBTPrinterManagerStatusEmptyQueue) {
        return [UIImage imageNamed:@"menuPrintQueueOn"];
    }
    
    return [UIImage imageNamed:@"menuPrintQueueOff"];
}

+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((PGSideBarMenuCellTakeSurvey == indexPath.row)  &&  ![NSLocale isSurveyAvailable]) {
        return 0.0F;
    } else if (IS_IPHONE_4 || IS_IPHONE_5) {
        return kPGSideBarMenuItemsSmallCellHeight;
    }
    
    return kPGSideBarMenuItemsRegularCellHeight;
}

@end
