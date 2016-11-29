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

#import <MP.h>

#import "PGSideBarMenuItems.h"

#import "UIColor+Style.h"

NSString * const kPrivacyStatementURL = @"http://www8.hp.com/us/en/privacy/privacy.html";
NSString * const kPrivacyStatementURLUk = @"http://www8.hp.com/uk/en/privacy/privacy.html";
NSString * const kPrivacyStatementURLDe = @"http://www8.hp.com/ch/de/privacy/privacy.html";
NSString * const kPrivacyStatementURLFr = @"http://www8.hp.com/ch/fr/privacy/privacy.html";
NSString * const kPrivacyStatementURLSp = @"http://www8.hp.com/es/es/privacy/privacy.html";

NSString * const kBuyPaperURL = @"http://www.hp.com/go/ZINKphotopaper";
NSString * const kSurveyURL = @"https://www.surveymonkey.com/r/Q99S6P5";
NSString * const kSurveyNotifyURL = @"www.surveymonkey.com/r/close-window";
NSString * const kBuyPaperScreenName = @"Buy Paper Screen";
NSString * const kPrivacyStatementScreenName = @"Privacy Statement Screen";

NSInteger const kPGSideBarMenuItemsNumberOfRows = 7;

CGFloat const kPGSideBarMenuItemsRegularCellHeight = 52.0f;
CGFloat const kPGSideBarMenuItemsSmallCellHeight = 42.0f;

@implementation PGSideBarMenuItems

+ (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    UIView *selectionColorView = [[UIView alloc] init];
    selectionColorView.backgroundColor = [UIColor HPTableRowSelectionColor];
    
    cell.selectedBackgroundView = selectionColorView;
    
    switch (indexPath.row) {
        case PGSideBarMenuCellSprocket:
            cell.textLabel.text = NSLocalizedString(@"sprocket", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuSprocket"];
            break;
        case PGSideBarMenuCellBuyPaper:
            cell.textLabel.text = NSLocalizedString(@"Buy Paper", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuBuyPaper"];
            break;
        case PGSideBarMenuCellHowToAndHelp:
            cell.textLabel.text = NSLocalizedString(@"How to & Help", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuHowToHelp"];
            break;
        case PGSideBarMenuCellGiveFeedback:
            cell.textLabel.text = NSLocalizedString(@"Give Feedback", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuGiveFeedback"];
            break;
        case PGSideBarMenuCellTakeSurvey:
            cell.textLabel.text = NSLocalizedString(@"Take Survey", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuTakeSurvey"];
            break;
        case PGSideBarMenuCellPrivacy:
            cell.textLabel.text = NSLocalizedString(@"Privacy", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuPrivacy"];
            break;
        case PGSideBarMenuCellAbout:
            cell.textLabel.text = NSLocalizedString(@"About", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuAbout"];
            break;
        default:
            break;
    }
    
    return cell;
}

+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((PGSideBarMenuCellTakeSurvey == indexPath.row)  &&  ![NSLocale isSurveyAvailable]) {
        return 0.0F;
    } else if (IS_IPHONE_4) {
        return kPGSideBarMenuItemsSmallCellHeight;
    }
    
    return kPGSideBarMenuItemsRegularCellHeight;
}

@end
