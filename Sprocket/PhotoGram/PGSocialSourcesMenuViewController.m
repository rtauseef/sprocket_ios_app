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

#import "PGSocialSourcesMenuViewController.h"
#import "PGSocialSource.h"
#import "PGSocialSourcesManager.h"
#import "PGSocialSourceMenuCellTableViewCell.h"

CGFloat const kPGSocialSourcesMenuCellHeight = 40;
NSInteger const kPGSocialSourcesMenuDefaultThreshold = 4;

@interface PGSocialSourcesMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *socialSoucesTableView;

@end

@implementation PGSocialSourcesMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGSocialSource *socialSource = [[PGSocialSource alloc] initWithSocialSourceType:indexPath.row];
    
    PGSocialSourceMenuCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PGSocialSourceMenuCell"];
    [cell configureCell:socialSource];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [PGSocialSourcesManager sharedInstance].enabledSocialSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPGSocialSourcesMenuCellHeight;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"reaching accessoryButtonTappedForRowWithIndexPath:");
}

@end

