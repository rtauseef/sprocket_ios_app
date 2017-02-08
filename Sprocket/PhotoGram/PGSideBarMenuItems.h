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

#import <Foundation/Foundation.h>
#import "NSLocale+Additions.h"

extern NSString * const kSurveyURL;
extern NSString * const kSurveyNotifyURL;
extern NSString * const kBuyPaperScreenName;
extern NSString * const kPrivacyStatementScreenName;

extern NSInteger const kPGSideBarMenuItemsNumberOfRows;

typedef NS_ENUM(NSInteger, PGSideBarMenuCell) {
    PGSideBarMenuCellSprocket,
    PGSideBarMenuCellBuyPaper,
    PGSideBarMenuCellHowToAndHelp,
    PGSideBarMenuCellGiveFeedback,
    PGSideBarMenuCellTakeSurvey,
    PGSideBarMenuCellPrivacy,
    PGSideBarMenuCellAbout,
    PGSideBarMenuCellLaunchMessageCenter,
};

@interface PGSideBarMenuItems : NSObject

+ (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
