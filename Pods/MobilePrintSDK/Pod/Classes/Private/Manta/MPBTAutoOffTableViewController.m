//
// HP Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "MPBTAutoOffTableViewController.h"
#import "MPBTSprocket.h"
#import "MP.h"
#import "NSBundle+MPLocalizable.h"

@interface MPBTAutoOffTableViewController ()

@property (strong, nonatomic) NSArray *autoOffTitles;
@property (strong, nonatomic) NSArray *autoOffValues;

@end

@implementation MPBTAutoOffTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.tableHeaderView.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralTableSeparatorColor];
    
    self.autoOffTitles = @[MPLocalizedString(@"Never", @"Indicates that the device will never power off"),
                           [MPBTSprocket autoPowerOffIntervalString:SprocketAutoOffTenMin],
                           [MPBTSprocket autoPowerOffIntervalString:SprocketAutoOffFiveMin],
                           [MPBTSprocket autoPowerOffIntervalString:SprocketAutoOffThreeMin]];
    
    self.autoOffValues = @[[NSNumber numberWithInt:SprocketAutoOffAlwaysOn],
                           [NSNumber numberWithInt:SprocketAutoOffTenMin],
                           [NSNumber numberWithInt:SprocketAutoOffFiveMin],
                           [NSNumber numberWithInt:SprocketAutoOffThreeMin]];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didPressBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.title = MPLocalizedString(@"Auto Off", @"Title of field displaying how many minutes the device is on before it automatically powers off");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPressBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getters/Setters

- (void)setCurrentAutoOffValue:(SprocketAutoPowerOffInterval)currentAutoOffValue
{
    _currentAutoOffValue = currentAutoOffValue;
    
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectAutoOffInterval:)]) {
        NSInteger rowValue = ((NSNumber *)(self.autoOffValues[indexPath.row])).integerValue;
        [self.delegate didSelectAutoOffInterval:(SprocketAutoPowerOffInterval)rowValue];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.autoOffTitles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPBTAutoOffCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MPBTAutoOffCell"];
    }
    
    cell.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    cell.textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    cell.textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    
    cell.textLabel.text = self.autoOffTitles[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger rowValue = ((NSNumber *)(self.autoOffValues[indexPath.row])).integerValue;
    if (rowValue == self.currentAutoOffValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;

}

@end
