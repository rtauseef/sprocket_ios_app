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

#import "PGSideBarMenuViewController.h"

static NSString *PGSideBarMenuCellIdentifier = @"PGSideBarMenuCell";

typedef NS_ENUM(NSInteger, PGSideBarMenuCell) {
    PGSideBarMenuCellSprocket,
    PGSideBarMenuCellBuyPaper,
    PGSideBarMenuCellHowToAndHelp,
    PGSideBarMenuCellGiveFeedback,
    PGSideBarMenuCellTakeSurvey,
    PGSideBarMenuCellPrivacy,
    PGSideBarMenuCellAbout,
};

@interface PGSideBarMenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainMenuTableView;

@end

@implementation PGSideBarMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UITableViewDatasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PGSideBarMenuCellIdentifier];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
