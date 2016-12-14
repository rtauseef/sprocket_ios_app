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

#import "PGSprocketLandingPageViewController.h"
#import "PGAppAppearance.h"
#import "PGRevealViewController.h"
#import "UIFont+Style.h"
#import "UIColor+Style.h"
#import "UIViewController+Trackable.h"

@interface PGSprocketLandingPageViewController () <UITableViewDataSource, UITableViewDelegate, MPSprocketDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *connectedSprocketName;

@end

@implementation PGSprocketLandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.trackableScreenName = @"Sprocket Landing Screen";
    
    [PGAppAppearance addGradientBackgroundToView:self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deselectRowTableViewCell)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self deselectRowTableViewCell];
    
    if ([[MP sharedInstance] numberOfPairedSprockets] == 1) {
        [[MP sharedInstance] checkSprocketForUpdates:self];
    } else {
        self.connectedSprocketName = nil;
        [self.tableView reloadData];
    }
}

- (void)deselectRowTableViewCell
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)didReceiveSprocketName:(NSString *)name
{
    self.connectedSprocketName = name;
    [self.tableView reloadData];
}

#pragma mark TableView Datasource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sprocketCellReuse"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor HPGrayColor];
    
    UIView *selectionColorView = [[UIView alloc] init];
    selectionColorView.backgroundColor = [UIColor HPTableRowSelectionColor];
    cell.selectedBackgroundView = selectionColorView;
    
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = NSLocalizedString(@"App Settings", nil);
            cell.detailTextLabel.hidden = YES;
            break;
        }
        case 1: {
            cell.textLabel.text = NSLocalizedString(@"Printers", nil);
            cell.detailTextLabel.hidden = NO;
            cell.detailTextLabel.text = self.connectedSprocketName;
            break;
        }
        default:
            break;
    }
    
    [cell layoutIfNeeded];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

#pragma mark TableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            [self openSettings];
            break;
        }
        case 1: {
            [[MP sharedInstance] presentBluetoothDevicesFromController:self animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

@end
