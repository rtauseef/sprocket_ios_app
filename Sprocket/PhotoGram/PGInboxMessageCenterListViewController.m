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
#import "UIFont+Style.h"
#import "PGInboxMessagePageViewController.h"

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
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 340;

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // refresh immediately with available local message list
    [self messageListUpdated];

    // update message list and refresh
    [self loadMessages];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refreshControlUpdated:(UIRefreshControl *)sender
{
    if (sender.isRefreshing) {
        [self loadMessages];
    }
}


#pragma mark - Private

- (void)loadMessages
{
    void (^retrieveMessageCompletionBlock)() = ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            [CATransaction begin];
            [CATransaction setCompletionBlock: ^{
                [self messageListUpdated];
            }];
            if (self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }
            [CATransaction commit];
        });
    };

    [[UAirship inbox].messageList retrieveMessageListWithSuccessBlock:retrieveMessageCompletionBlock withFailureBlock:retrieveMessageCompletionBlock];
}

- (void)messageListUpdated
{
    self.messages = [NSArray arrayWithArray:[UAirship inbox].messageList.messages];

    if (self.messages.count > 0) {
        self.tableView.backgroundView = nil;

    } else {
        UIView *view = [[UIView alloc] init];

        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont HPSimplifiedLightFontWithSize:20.0];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 2;
        label.adjustsFontSizeToFitWidth = YES;
        label.text = NSLocalizedString(@"Check back soon for cool sprocket tips, fun project ideas, and app updates!", nil);
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;

        [view addSubview:label];

        self.tableView.backgroundView = view;

        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:view
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0.0];

        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:view
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0.0];

        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:view
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:0.8
                                                                    constant:0.0];

        [NSLayoutConstraint activateConstraints:@[centerX, centerY, width]];

        [view layoutIfNeeded];
        [label layoutIfNeeded];
    }

    [self.tableView reloadData];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];

    PGInboxMessagePageViewController *viewController = (PGInboxMessagePageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGInboxMessagePageViewController"];
    viewController.messages = self.messages;
    viewController.focusedMessageIndex = indexPath.row;

    [self.navigationController pushViewController:viewController animated:YES];
}

@end
