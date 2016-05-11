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

#import "HPPRSelectAlbumTableViewController.h"
#import "HPPR.h"
#import "HPPRCacheService.h"
#import "HPPRSelectAlbumTableViewCell.h"
#import "HPPRSelectPhotoProvider.h"
#import "UIView+HPPRAnimation.h"
#import "UIColor+HPPRStyle.h"
#import "NSBundle+HPPRLocalizable.h"

NSString * const kAlbumSelectionScreenName = @"Album Selection Screen";

@interface HPPRSelectAlbumTableViewController() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, getter = isRefreshingAlbums) BOOL refreshingAlbums;
@property (strong, nonatomic) NSArray *albums;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation HPPRSelectAlbumTableViewController

@dynamic refreshControl;

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.title = [NSString stringWithFormat:HPPRLocalizedString(@"%@ Albums", @"Albums of the specified social network"), self.provider.localizedName];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.albums = @[];
    
    if (!self.isRefreshingAlbums) {
        self.refreshingAlbums = YES;
        [self.provider albumsWithRefresh:NO andCompletion:^(NSArray *albums, NSError *error) {
            if (!error) {
                self.albums = albums;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.refreshControl = [[UIRefreshControl alloc] init];
                [self.refreshControl setTintColor:[UIColor HPPRBlueColor]];
                [self.refreshControl addTarget:self action:@selector(startRefreshing:) forControlEvents:UIControlEventValueChanged];
                [self.tableView addSubview:self.refreshControl];
                
                [self.tableView reloadData];
            });
            
            self.refreshingAlbums = NO;
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumChange:) name:HPPR_ALBUM_CHANGE_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_TRACKABLE_SCREEN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@ %@", self.provider.name, kAlbumSelectionScreenName] forKey:kHPPRTrackableScreenNameKey]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification methods

- (void)albumChange:(NSNotification *)notification
{
    if (!self.isRefreshingAlbums) {
        self.refreshingAlbums = YES;
        
        [self.provider albumsWithRefresh:YES andCompletion:^(NSArray *albums, NSError *error) {
            if (!error) {
                self.albums = albums;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            self.refreshingAlbums = NO;
        }];
    }
}

#pragma mark - Pull to refresh

- (void)startRefreshing:(UIRefreshControl *)refreshControl
{
    if (!self.isRefreshingAlbums) {
        self.refreshingAlbums = YES;
        
        [self.provider albumsWithRefresh:YES andCompletion:^(NSArray *albums, NSError *error) {
            if (!error) {
                self.albums = albums;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                if (self.refreshControl.refreshing) {
                    [self.refreshControl endRefreshing];
                }
            });
            
            self.refreshingAlbums = NO;
        }];
    }
}

#pragma mark - Table Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *myIdentifier = @"AlbumCell";
    
    HPPRSelectAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    
    if (cell == nil) {
        cell = [[HPPRSelectAlbumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.album = [self.albums objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albums.count;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HPPRSelectAlbumTableViewCell *cell = (HPPRSelectAlbumTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.provider.album = cell.album;
    [self performSegueWithIdentifier:@"SelectPhotosSegue" sender:self];
}

#pragma mark - Button actions

- (IBAction)backButtonTapped:(id)sender
{
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    
    if (vc == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"SelectPhotosSegue" isEqual:segue.identifier]) {
        HPPRSelectPhotoCollectionViewController *vc = (HPPRSelectPhotoCollectionViewController *)[segue destinationViewController];
        vc.delegate = self.delegate;
        vc.provider = self.provider;
    }
}

@end
