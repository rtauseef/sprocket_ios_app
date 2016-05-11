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

#import "HPPRSearchViewController.h"
#import "HPPR.h"
#import "HPPRSegmentedControlView.h"
#import "HPPRInstagramTag.h"
#import "HPPRInstagramUser.h"
#import "HPPRNoInternetConnectionRetryView.h"
#import "HPPRCacheService.h"
#import "HPPRInstagramError.h"
#import "HPPRInstagram.h"
#import "HPPRInstagramPhotoProvider.h"
#import "UIImage+HPPRMaskImage.h"
#import "UIFont+HPPRStyle.h"
#import "NSBundle+HPPRLocalizable.h"

// Declaring these as const variables produced warnings in calls where they were used...
static int       kHashtagIndex  = 0;
static int       kUserIndex     = 1;


@interface HPPRSearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, HPPRNoInternetConnectionRetryViewDelegate, HPPRSegmentedControlViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet HPPRSegmentedControlView *segmentedControlView;
@property (weak, nonatomic) IBOutlet UITableView *resultsTable;
@property (weak, nonatomic) IBOutlet HPPRNoInternetConnectionRetryView *noInternetConnectionRetryView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *noSearchResultsLabel;
@property long selectedRow;
@property UIImage *selectedUserImage;
@property NSArray *searchResults;
@property (strong, nonatomic) NSString *savedTitle;
@property (strong, nonatomic) UIAlertView *showLandingPageAlert;


@end

@implementation HPPRSearchViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = HPPRLocalizedString(@"Search", @"Title of the search screen for Instagram tags");
    self.noSearchResultsLabel.text = HPPRLocalizedString(@"No results found", @"Message show to the user when there is no results in the search");
    
    self.resultsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.searchResults = nil;
    
    self.resultsTable.dataSource = self;
    self.resultsTable.delegate = self;
    self.searchBar.delegate = self;
    self.noInternetConnectionRetryView.delegate = self;
    self.segmentedControlView.delegate = self;
    
    self.activityIndicator.hidden = YES;
    self.noInternetConnectionRetryView.hidden = YES;
    
    [self initSegmentedControl];
    
    self.selectedRow = 0;
    self.selectedUserImage = nil;
    
    self.savedTitle = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if( nil != self.savedTitle ) {
        self.title = self.savedTitle;
    }
    
    if( 0 == [self.searchBar.text length] ) {
        [self.searchBar becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // This may be redundant to the call in viewWillAppear
    //  However, I don't have an iOS7 device to test with.
    //  So, leaving it in, just in case...
    if( 0 == [self.searchBar.text length] ) {
        [self.searchBar becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.savedTitle = [(UINavigationItem *)self.navigationItem title];
    self.title = @" ";
    
    if (self.isMovingFromParentViewController) {
        HPPRInstagramPhotoProvider * provider = [HPPRInstagramPhotoProvider sharedInstance];
        [provider initForStandardDisplay];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([@"SelectPhotoFromSearchSegue"  isEqual: segue.identifier]) {
        HPPRSelectPhotoCollectionViewController *vc = [segue destinationViewController];
        vc.delegate = self.delegate;
        NSDictionary *item = [self.searchResults objectAtIndex:self.selectedRow];
        HPPRInstagramPhotoProvider *provider = [HPPRInstagramPhotoProvider sharedInstance];
        if( kHashtagIndex == self.segmentedControlView.selectedSegmentIndex ) {
            [provider initWithHashtag:[item objectForKey:@"name"] withNumPosts:[item objectForKey:@"media_count"]];
        }
        else {
            [provider initWithUsername:[item objectForKey:@"username"] andUserId:[item objectForKey:@"id"] andImage:self.selectedUserImage];
        }
        vc.provider = provider;
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search button clicked");
    
    if( [searchBar.text length] ) {
        
        // Hide the errors
        self.noInternetConnectionRetryView.hidden = YES;
        
        // Make sure no results label is hidden when starting new search
        self.noSearchResultsLabel.hidden = YES;
        
        // Hide the keyboard
        [self.view endEditing:YES];
        
        // clear the table
        self.searchResults = nil;
        [self.resultsTable reloadData];
        
        // show a progress indicator
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        
        // we run the same completion block for both the hashtag and user cases
        void (^completionBlock)(NSArray *, NSError *) = ^(NSArray *results, NSError *error) {
            if( nil != error ) {
                HPPRInstagramErrorType instagramError = [HPPRInstagramError errorType:error];
                
                switch (instagramError) {
                    case INSTAGRAM_NO_INTERNET_CONNECTION:
                        self.noInternetConnectionRetryView.hidden = NO;
                        break;
                        
                    case INSTAGRAM_TOKEN_IS_INVALID:
                        [self lostAccess];
                        break;
                        
                    case INSTAGRAM_OP_COULD_NOT_COMPLETE:
                        // unexpected result for this screen!
                    case INSTAGRAM_USER_ACCOUNT_IS_PRIVATE:
                        // unexpected result for this screen!
                    case INSTAGRAM_UNRECOGNIZED_ERROR:
                    default:
                        break;
                }
                
            }
            else {
                if (results.count > 0) {
                    self.searchResults = results;
                    [self.resultsTable reloadData];
                } else {
                    self.noSearchResultsLabel.hidden = NO;
                }
            }
            
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
        };
        
        // execute the queries using the completion block
        if( 0 == self.segmentedControlView.selectedSegmentIndex ) {
            [HPPRInstagramTag tagSearch:[searchBar text] completion:completionBlock];
        }
        else {
            [HPPRInstagramUser userSearch:[searchBar text] completion:completionBlock];
        }
    }
}

#pragma mark - Helpers

- (void)initSegmentedControl
{
    NSString *hastagStringLocalize = HPPRLocalizedString(@"Hashtag", @"Option of the search screen of instagram, the user can search hashtags (this option) or photos of other users");
    [self.segmentedControlView setTitle:hastagStringLocalize forSegmentAtIndex:kHashtagIndex state:UIControlStateNormal];
    [self.segmentedControlView setTitle:hastagStringLocalize forSegmentAtIndex:kHashtagIndex state:UIControlStateSelected];
    
    NSString *userStringLocalize = HPPRLocalizedString(@"Users", @"Option of the search screen of instagram, the user can search hashtags or photos of other users (this option)");
    [self.segmentedControlView setTitle:userStringLocalize forSegmentAtIndex:kUserIndex state:UIControlStateSelected];
    [self.segmentedControlView setTitle:userStringLocalize forSegmentAtIndex:kUserIndex state:UIControlStateNormal];
}

#pragma mark - Table Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myIdentifier = @"SearchViewCell";
    
    __block UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    if( nil != self.searchResults ) {
        
        cell.textLabel.font = [UIFont HPPRSimplifiedRegularFontWithSize:14.0f];
        cell.detailTextLabel.font = [UIFont HPPRSimplifiedLightFontWithSize:14.0f];
        
        if( 0 == self.segmentedControlView.selectedSegmentIndex ) {
            NSDictionary *item = (NSDictionary *)[self.searchResults objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"#%@", [item objectForKey:@"name"]];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = nil;
            cell.detailTextLabel.text = nil;
        }
        else {
            NSDictionary *item = (NSDictionary *)[self.searchResults objectAtIndex:indexPath.row];
            cell.textLabel.text = [item objectForKey:@"username"];
            cell.detailTextLabel.text = [item objectForKey:@"full_name"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            NSString *url = [item objectForKey:@"profile_picture"];
            [UIImage HPPRMaskImageWithURL:url diameter:cell.frame.size.height * 0.723156 borderWidth:0.0f completion:^(UIImage *circleImage) {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    cell.imageView.image = circleImage;
                    [cell setNeedsLayout];
                });
            }];
        }
    } else {
        // clear the cell
        cell.textLabel.text = nil;
        cell.imageView.image = nil;
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedRow = indexPath.row;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedUserImage = cell.imageView.image;
    
    [self performSegueWithIdentifier:@"SelectPhotoFromSearchSegue" sender:self];
}

#pragma mark - PGNoInternetConnectionRetryViewDelegate

- (void)noInternetConnectionRetryViewDidTapRetry:(HPPRNoInternetConnectionRetryView *)noInternetConnectionRetryView {
    [self searchBarSearchButtonClicked:self.searchBar];
}

#pragma mark - PGSegmentedControlViewDelegate

- (void)segmentedControlViewDidChange:(HPPRSegmentedControlView *)segmentedControlView {
    [self searchBarSearchButtonClicked:self.searchBar];
}

#pragma mark - Login Expiration Handling (including UIAlertViewDelegate)

- (void)lostAccess
{
    UIAlertView *alertView = self.provider.lostAccessAlertView;
    alertView.delegate = self;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.provider resetAccess];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
