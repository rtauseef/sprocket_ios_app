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
#import "PGRevealViewController.h"

CGFloat const kPGSocialSourcesMenuCellHeight = 40;
NSInteger const kPGSocialSourcesMenuDefaultThreshold = 4;

@interface PGSocialSourcesMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *socialSoucesTableView;

@end

@implementation PGSocialSourcesMenuViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.socialSoucesTableView reloadData];
    });
}

#pragma mark - UITableViewDatasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGSocialSource *socialSource = [PGSocialSourcesManager sharedInstance].enabledSocialSources[indexPath.row];
    
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
    PGSocialSource *socialSource = [PGSocialSourcesManager sharedInstance].enabledSocialSources[indexPath.row];
    
    if (!socialSource.photoProvider) {
        return;
    }
    
    [self showSocialNetwork:socialSource.photoProvider.name includeLogin:(socialSource.needsSignIn ? !socialSource.isLogged : NO)];
}

#pragma mark - Show Social Sources

- (void)showSocialNetwork:(NSString *)socialNetwork includeLogin:(BOOL)includeLogin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.revealViewController revealToggleAnimated:YES];
        [self.socialSoucesTableView deselectRowAtIndexPath:[self.socialSoucesTableView indexPathForSelectedRow] animated:YES];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: socialNetwork, kSocialNetworkKey, [NSNumber numberWithBool:includeLogin], kIncludeLoginKey, nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_SOCIAL_NETWORK_NOTIFICATION object:nil userInfo:userInfo];
    });
}

@end

