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

#import "MPBTPairedAccessoriesViewController.h"
#import "MPBTSessionController.h"
#import "MPBTSprocket.h"
#import "MP.h"
#import "NSBundle+MPLocalizable.h"
#import "MPBTDeviceInfoTableViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface MPBTPairedAccessoriesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *pairedDevices;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *noDevicesView;
@property (weak, nonatomic) IBOutlet UILabel *noDevicesLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;

@end

@implementation MPBTPairedAccessoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setTitle:@"Devices"];
    self.bottomView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralTableSeparatorColor];
    
    self.topView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.containerView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    if ([UINavigationBar appearance].barTintColor) {
        self.topView.backgroundColor = [UINavigationBar appearance].barTintColor;
        self.containerView.backgroundColor = [UINavigationBar appearance].barTintColor;
    }

    if ([UINavigationBar appearance].titleTextAttributes) {
        self.titleLabel.font = [[UINavigationBar appearance].titleTextAttributes objectForKey:NSFontAttributeName];
        self.titleLabel.textColor = [[UINavigationBar appearance].titleTextAttributes objectForKey:NSForegroundColorAttributeName];
    } else {
        self.titleLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
        self.titleLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    }

    self.noDevicesLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.noDevicesLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.descriptionLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.descriptionLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    if ([UINavigationController class] == [self.parentViewController class]) {
        self.topViewHeightConstraint.constant = 0;
        self.topView.hidden = YES;
        self.showDisclosureIndicator = YES;
    }
    
    [self didPressRefreshButton:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)presentAnimated:(BOOL)animated usingController:(UIViewController *)hostController andCompletion:(void(^)(void))completion
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MPBTPairedAccessoriesNavigationController"];
    [hostController presentViewController:navigationController animated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell	*cell;
    static NSString *cellID = @"EAAccessoryList";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    EAAccessory *accessory = (EAAccessory *)[self.pairedDevices objectAtIndex:indexPath.row];
    
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@ (%@)", accessory.name, accessory.serialNumber]];
    cell.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    cell.textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    cell.textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    if (self.showDisclosureIndicator) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = self.pairedDevices.count;
    
    self.noDevicesView.hidden = (0 == numRows) ? NO : YES;

    return numRows;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EAAccessory *device = (EAAccessory *)[self.pairedDevices objectAtIndex:indexPath.row];
    MPBTSprocket *sprocket = [MPBTSprocket sharedInstance];
    sprocket.accessory = device;

    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectSprocket:)]) {
        void (^completionBlock)(void) = ^{
            [self.delegate didSelectSprocket:sprocket];
            
            if (self.completionBlock) {
                self.completionBlock(YES);
            }
        };

        if (nil == self.parentViewController) {
            [self dismissViewControllerAnimated:YES completion:completionBlock];
        } else {
            completionBlock();
        }
    } else {
        // show device info screen
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:[NSBundle bundleForClass:[MP class]]];
        MPBTDeviceInfoTableViewController *settingsViewController = (MPBTDeviceInfoTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MPBTDeviceInfoTableViewController"];
        settingsViewController.device = sprocket.accessory;
        
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        
        [((UINavigationController *)topController) pushViewController:settingsViewController animated:YES];
    }
}

#pragma mark - Button Listeners

- (IBAction)didPressRefreshButton:(id)sender {
    [self refreshPairedDevices];
    
    if (0 == self.pairedDevices.count) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MPLocalizedString(@"Printer not connected to device", @"Title of dialog letting the user know that there is no sprocket paired with their phone")
                                                                       message:MPLocalizedString(@"Make sure the printer is turned on and check the Bluetooth connection.", @"Body of dialog letting the user know that there is no sprocket paired with their phone")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:MPLocalizedString(@"Settings", @"Button that takes the user to the phone's Settings screen")
                                                                 style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
                                                                  [[UIApplication sharedApplication] openURL:url];
                                                              }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:MPLocalizedString(@"OK", @"Dismisses dialog without taking action")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        [alert addAction:okAction];
        [alert addAction:settingsAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)didPressCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Util

- (void)becomeActive:(NSNotification *)notification {
    [self refreshPairedDevices];
}

- (void)refreshPairedDevices
{
    self.pairedDevices = [MPBTSprocket pairedSprockets];
    [self.tableView reloadData];
}

@end
