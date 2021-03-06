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
#import "MPBTProgressView.h"
#import "MPBTTechnicalInformationViewController.h"
#import "MPBTStatusChecker.h"
#import "MPBTImageProcessor.h"

#import <ExternalAccessory/ExternalAccessory.h>
#import <CoreBluetooth/CBCentralManager.h>

static NSString *kMPBTLastPrinterNameSetting = @"kMPBTLastPrinterNameSetting";
static NSString * const kDeviceListScreenName = @"Devices Screen";
static const NSInteger kMPBTPairedAccessoriesRecentSection = 0;
static const NSInteger kMPBTPairedAccessoriesOtherSection  = 1;

typedef enum : NSUInteger {
    PairedAccessoriesViewControllerModeForPrint,
    PairedAccessoriesViewControllerModeForDeviceInfo
} PairedAccessoriesViewControllerMode;

@interface MPBTPairedAccessoriesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *pairedDevices;
@property (strong, nonatomic) EAAccessory *recentDevice;
@property (strong, nonatomic) NSMutableArray *otherDevices;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *noDevicesView;
@property (weak, nonatomic) IBOutlet UILabel *noDevicesLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (assign, nonatomic) BOOL presentedNoDevicesModal;

@property (assign, nonatomic) PairedAccessoriesViewControllerMode mode;
@property (strong, nonatomic) MPBTImageProcessor *processor;

@end

@implementation MPBTPairedAccessoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
    self.noDevicesLabel.text = MPLocalizedString(@"No sprockets Connected", @"Indicates that no sprocket printers are connected");
    self.descriptionLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.descriptionLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
    self.descriptionLabel.text = MPLocalizedString(@"Pair your bluetooth sprocket printer with this device. Make sure the sprocket printer is on and bluetooth connected.", @"Instructions for pairing a printer");
    self.presentedNoDevicesModal = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didPressBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    if ([UINavigationController class] == [self.parentViewController class]) {
        self.topViewHeightConstraint.constant = 0;
        self.topView.hidden = YES;
    }
    
    [self setupTitle];
    [self refreshPairedDevices];
    
    if (0 == self.pairedDevices.count && !self.presentedNoDevicesModal) {
        self.presentedNoDevicesModal = YES;
        [self presentNoPrinterConnectedAlert:nil showConnectSprocket:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kDeviceListScreenName forKey:kMPTrackableScreenNameKey]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupTitle
{
    if (self.mode == PairedAccessoriesViewControllerModeForPrint) {
        [self setTitle:MPLocalizedString(@"Select Printer", @"Title for screen listing all available sprocket printers")];
    } else {
        [self setTitle:MPLocalizedString(@"sprocket", @"Title for screen listing all available sprocket printers")];
    }
}

- (void)didPressBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

+ (instancetype)pairedAccessoriesViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:nil];
    MPBTPairedAccessoriesViewController *vc = (MPBTPairedAccessoriesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MPBTPairedAccessoriesViewController"];

    return vc;
}

+ (instancetype)pairedAccessoriesViewControllerForPrint {
    MPBTPairedAccessoriesViewController *vc = [self pairedAccessoriesViewController];
    vc.mode = PairedAccessoriesViewControllerModeForPrint;

    return vc;
}

+ (instancetype)pairedAccessoriesViewControllerForDeviceInfo {
    MPBTPairedAccessoriesViewController *vc = [self pairedAccessoriesViewController];
    vc.mode = PairedAccessoriesViewControllerModeForDeviceInfo;

    return vc;
}

+ (void)presentAnimatedForDeviceInfo:(BOOL)animated usingController:(UIViewController *)hostController andCompletion:(void(^)(void))completion
{
    UIViewController *vc = [self pairedAccessoriesViewControllerForDeviceInfo];
    
    [hostController showViewController:vc sender:nil];
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
    
    cell.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    cell.textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    cell.textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];

    if (!self.noDevicesView.hidden) {
        [[cell textLabel] setText:MPLocalizedString(@"Technical Information", @"Title of table view cell used for displaying technical information")];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        EAAccessory *accessory = (EAAccessory *)[self.pairedDevices objectAtIndex:indexPath.row];
        if ([self numberOfSectionsInTableView:tableView] > 1) {
            
            if (kMPBTPairedAccessoriesRecentSection == indexPath.section) {
                accessory = self.recentDevice;
            } else {
                accessory = (EAAccessory *)[self.otherDevices objectAtIndex:indexPath.row];
            }
        }
        
        [[cell textLabel] setText:[MPBTSprocket displayNameForAccessory:accessory]];
        if (self.mode == PairedAccessoriesViewControllerModeForPrint) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numSections = (self.recentDevice) ? 2 : 1;
    
    return numSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if ([self numberOfSectionsInTableView:tableView] > 1) {
        if (kMPBTPairedAccessoriesRecentSection == section) {
            title = MPLocalizedString(@"Recent Printer", @"Table heading for the printer that has most recently been printed to");
        } else if (kMPBTPairedAccessoriesOtherSection == section) {
            title = MPLocalizedString(@"Other Printers", @"Table heading for list of all available printers, except for the most recently used printer");
        }
    }
    
    return title;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = self.pairedDevices.count;
    self.noDevicesView.hidden = (0 == numRows) ? NO : YES;
    
    if ([self numberOfSectionsInTableView:tableView] > 1) {
        self.noDevicesView.hidden = YES;
        
        if (kMPBTPairedAccessoriesRecentSection == section) {
            numRows = 1;
        } else {
            numRows = self.otherDevices.count;
        }
    }
    
    if (!self.noDevicesView.hidden) {
        numRows = 1;
    }
    
    return numRows;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = tableView.sectionHeaderHeight;
    
    if ([self numberOfSectionsInTableView:tableView] > 1) {
        height = 35.0F;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = tableView.sectionHeaderHeight;
    
    if ([self numberOfSectionsInTableView:tableView] > 1) {
        height = 10.0F;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    header.textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPMainActionInactiveLinkFontColor];
    header.textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    footer.contentView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.noDevicesView.hidden) {
#ifndef TARGET_IS_EXTENSION
        // show device info screen
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:[NSBundle bundleForClass:[MP class]]];
        MPBTTechnicalInformationViewController *techInfoViewController = (MPBTTechnicalInformationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MPBTTechnicalInformationViewController"];
        
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        
        techInfoViewController.title = MPLocalizedString(@"Technical Information", @"Title of Technical Information screen");
        [((UINavigationController *)topController) pushViewController:techInfoViewController animated:YES];
#endif
    } else {
        // ensure that the device is still connected
        EAAccessory *accessory = nil;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *displayName = cell.textLabel.text;
        
        NSArray *currentlyPairedDevices = [MPBTSprocket pairedSprockets];
        for (EAAccessory *acc in currentlyPairedDevices) {
            if ([displayName isEqualToString:[MPBTSprocket displayNameForAccessory:acc]]) {
                accessory = acc;
            }
        }
        
        if (nil != accessory) {
            [MPBTSprocket sharedInstance].accessory = accessory;
            
            if (self.completionBlock) {
                if (nil == self.parentViewController) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        self.completionBlock(YES);
                    }];
                } else {
                    self.completionBlock(YES);
                }
            } else {
#ifndef TARGET_IS_EXTENSION
                // show device info screen
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:[NSBundle bundleForClass:[MP class]]];
                MPBTDeviceInfoTableViewController *settingsViewController = (MPBTDeviceInfoTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MPBTDeviceInfoTableViewController"];
                settingsViewController.device = [MPBTSprocket sharedInstance].accessory;
                
                UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
                
                while (topController.presentedViewController) {
                    topController = topController.presentedViewController;
                }
                
                [((UINavigationController *)topController) pushViewController:settingsViewController animated:YES];
#endif
            }
        } else {
            [self refreshPairedDevices];
        }
    }
}

#pragma mark - Button Listeners

- (IBAction)didPressCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Util

- (EAAccessory *)lastAccessoryUsed
{
    EAAccessory *lastAccessory = nil;
    NSString *lastPrinterUsedName = [MPBTPairedAccessoriesViewController lastPrinterUsed];
    
    for (EAAccessory *acc in self.pairedDevices) {
        if ([[MPBTSprocket displayNameForAccessory:acc] isEqualToString:lastPrinterUsedName]) {
            lastAccessory = acc;
            break;
        }
    }
    
    return lastAccessory;
}

+ (void)setLastPrinterUsed:(NSString *)lastPrinterUsed
{
    [[NSUserDefaults standardUserDefaults] setObject:lastPrinterUsed forKey:kMPBTLastPrinterNameSetting];
}

+ (NSString *)lastPrinterUsed
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kMPBTLastPrinterNameSetting];
}

- (void)presentNoPrinterConnectedAlert:(UIViewController *)hostController showConnectSprocket:(BOOL)showConnectSprocket
{
#ifndef TARGET_IS_EXTENSION
    if (![[MPBTStatusChecker sharedInstance] isBluetoothEnabled]) {
        if (showConnectSprocket) {
            // The following call forces the system "Connect to Bluetooth" dialog if bluetooth has been turned off
            CBCentralManager *cbManager = [[CBCentralManager alloc] initWithDelegate:nil queue: nil];
            cbManager = nil;
        }
    } else
#endif
        if (showConnectSprocket) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:MPLocalizedString(@"Sprocket Printer Not Connected", @"Message given when sprocket cannot be reached")
                                                                           message:MPLocalizedString(@"Make sure the sprocket printer is on and bluetooth connected.", @"Message given when the printer can't be contacted.")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:MPLocalizedString(@"OK", @"Dismisses dialog without taking action")
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
            [alert addAction:okAction];

            if (!hostController) {
                hostController = self;
            }
            [hostController presentViewController:alert animated:YES completion:nil];
            
            NSString *source = @"Print";
            if (self.mode == PairedAccessoriesViewControllerModeForDeviceInfo) {
                source = @"DeviceInfo";
            }

            NSDictionary *dictionary = @{kMPBTPrinterNotConnectedSourceKey : source};
            [[NSNotificationCenter defaultCenter] postNotificationName:kMPBTPrinterNotConnectedNotification object:nil userInfo:dictionary];
        }
}

- (void)becomeActive:(NSNotification *)notification {
    [self refreshPairedDevices];
}

- (void)refreshPairedDevices
{
    self.otherDevices = [[NSMutableArray alloc] init];
    self.recentDevice = nil;
    self.pairedDevices = [MPBTSprocket pairedSprockets];
    
    if (self.mode == PairedAccessoriesViewControllerModeForPrint) {
        self.recentDevice = [self lastAccessoryUsed];
        if (self.recentDevice) {
            for (EAAccessory *acc in self.pairedDevices) {
                if (![[MPBTSprocket displayNameForAccessory:acc] isEqualToString:[MPBTSprocket displayNameForAccessory:self.recentDevice]]) {
                    [self.otherDevices addObject:acc];
                }
            }
        }
    }
    
    [self.tableView reloadData];
}

@end
