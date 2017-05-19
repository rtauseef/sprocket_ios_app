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

#import "PGInboxMessageCenterListViewController.h"
#import "PGInboxMessageCenterTableViewCell.h"

#import <AirshipKit.h>

@interface PGInboxMessageCenterListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray<UAInboxMessage *> *messages;

@end

@implementation PGInboxMessageCenterListViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.title = NSLocalizedString(@"Inbox", nil);

        [self loadMessages];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlUpdated) forControlEvents:UIControlEventValueChanged];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 328;

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private

- (void)refreshControlUpdated
{
    if (self.refreshControl.isRefreshing) {
        [self loadMessages];
    }
}

- (void)loadMessages {

    void (^retrieveMessageCompletionBlock)() = ^(void){
        [CATransaction begin];
        [CATransaction setCompletionBlock: ^{
            [self messageListUpdated];
        }];
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
        [CATransaction commit];
    };

    [[UAirship inbox].messageList retrieveMessageListWithSuccessBlock:retrieveMessageCompletionBlock withFailureBlock:retrieveMessageCompletionBlock];
}

- (void)messageListUpdated
{
    self.messages = [NSArray arrayWithArray:[UAirship inbox].messageList.messages];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGInboxMessageCenterTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PGInboxMessageCenterTableViewCell"];
    cell.message = [self.messages objectAtIndex:indexPath.row];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

@end
