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

#import <Crashlytics/Crashlytics.h>
#import <MP.h>
#import "AirshipKit.h"
#import "PGAppDelegate.h"
#import "PGLoggingSetttingsViewController.h"
#import "PGAnalyticsManager.h"
#import "Logging/PGLog.h"
#import "Logging/PGLogger.h"
#import "Logging/PGLogFormatter.h"
#import "PGSocialSourcesManager.h"
#import "PGFeatureFlag.h"
#import "PGLinkSettings.h"

NSString *kPGSettingsForceFirmwareUpgrade = @"kPGSettingsForceFirmwareUpgrade";

static NSString* kLogLevelCellID = @"logLevelCell";
static NSString* kPickerCellID   = @"levelPickerCell";

static NSString* kErrorString    = @"Error";
static NSString* kWarnString     = @"Warning";
static NSString* kInfoString     = @"Info";
static NSString* kDebugString    = @"Debug";
static NSString* kVerboseString  = @"Verbose";

enum {
    kPhotogramCellIndex = 0,
    kSvgCellIndex,
    kClearLogsCellIndex,
    kTestLogsCellIndex,
    kMailLogsCellIndex,
    kCrashAppCellIndex,
    kExceptionAppCellIndex,
    kHideSvgMessagesIndex,
    kEnableExtraSocialSourcesIndex,
    kEnablePushNotificationsIndex,
    kDisplayNotificationMsgCenterIndex,
    kEnableWatermarkIndex,
    kEnableVideoPrintIndex,
    kEnableFakePrintIndex,
    kEnableLocalWatermarkIndex,
    kEnableVideoAR,
    kEnableVideoARParticles,
    kForceUpgradeIndex,
    
    kCellIndexMax // keep this on last position so we have a source for number of rows
};




NSString * const kFeatureCodeAll = @"hpway";
NSString * const kFeatureCodeLink = @"link";

@interface PGLoggingSetttingsViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSIndexPath *pickerIndexPath;
@property (assign) NSInteger pickerCellRowHeight;
@property (weak, nonatomic) UITableViewCell *photogramCell;
@property (weak, nonatomic) UITableViewCell *svgCell;
@property (weak, nonatomic) UIPickerView *pickerView;

@end

@implementation PGLoggingSetttingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPickerCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPickerCellID];
    }
    self.pickerCellRowHeight = cell.frame.size.height;
}

#pragma mark - Cells

- (UITableViewCell *)createLogLevelCell:(NSString *)title logLevel:(NSString *)logLevel
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kLogLevelCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kLogLevelCellID];
    }
    cell.textLabel.text = title;
    
    cell.detailTextLabel.text = logLevel;
    
    return cell;
    
}

- (UITableViewCell *)createPickerCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPickerCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPickerCellID];
    }
    
    self.pickerView = (UIPickerView *)[cell.contentView subviews][0];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    return cell;
}

#pragma mark - Picker

- (BOOL)levelPickerIsShown
{
    
    return self.pickerIndexPath != nil;
}

- (void)hideExistingPicker
{
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pickerIndexPath.row inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    self.pickerIndexPath = nil;
}


- (NSIndexPath *)calculateIndexPathForNewPicker:(NSIndexPath *)selectedIndexPath
{
    NSIndexPath *newIndexPath;
    
    if (([self levelPickerIsShown]) && (self.pickerIndexPath.row < selectedIndexPath.row)){
        
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row - 1 inSection:0];
        
    }else {
        
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row  inSection:0];
        
    }
    
    return newIndexPath;
}

- (void)showNewPickerAtIndex:(NSIndexPath *)indexPath
{
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = self.tableView.rowHeight;
    
    if ([self levelPickerIsShown] && (self.pickerIndexPath.row == indexPath.row)){
        
        rowHeight = self.pickerCellRowHeight;
        
    }
    
    if (![self enableFeature:indexPath.row forCode:self.unlockCode]) {
        rowHeight = 0.0;
    }
    
    return rowHeight;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = kCellIndexMax;
    
    if ([self levelPickerIsShown]){
        
        numberOfRows++;
        
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ([self levelPickerIsShown] && (self.pickerIndexPath.row == indexPath.row)){
        
        cell = [self createPickerCell];
        
    } else {
        NSUInteger selectedRow = indexPath.row;
        if ([self levelPickerIsShown] && selectedRow > self.pickerIndexPath.row) {
            selectedRow--;
        }

        
        if( kPhotogramCellIndex == selectedRow ) {
            self.photogramCell = [self createLogLevelCell: @"Photogram" logLevel:[self stringForLogLevel:pgLogLevel]];
            cell = self.photogramCell;
        } else if (kSvgCellIndex == selectedRow ) {
            self.svgCell = [self createLogLevelCell: @"SVG/Other" logLevel:[self stringForLogLevel:(ddLogLevel << PG_LOG_SHIFT)]];
            cell = self.svgCell;
        } else if( kMailLogsCellIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"mailLogs"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mailLogs"];
            }
            #if TARGET_IPHONE_SIMULATOR
                cell.textLabel.text = @"Mail logs - BROKEN ON SIMULATOR";
            #else
                cell.textLabel.text = @"Mail logs";
            #endif
            cell.textLabel.font = self.photogramCell.textLabel.font;
        } else if( kClearLogsCellIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"clearLogs"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearLogs"];
            }
            cell.textLabel.text = @"Clear logs";
            cell.textLabel.font = self.photogramCell.textLabel.font;
        } else if( kTestLogsCellIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"testLogs"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"testLogs"];
            }
            cell.textLabel.text = @"Generate test messages";
            cell.textLabel.font = self.photogramCell.textLabel.font;
        } else if (kCrashAppCellIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"crashApp"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"crashApp"];
            }
            cell.textLabel.text = @"Crash app";
            cell.textLabel.font = self.photogramCell.textLabel.font;
        } else if (kExceptionAppCellIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"throwException"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"throwException"];
            }
            cell.textLabel.text = @"Throw Exception";
            cell.textLabel.font = self.photogramCell.textLabel.font;
        } else if (kHideSvgMessagesIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"hideSvgMsgs"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"hideSvgMsgs"];
            }
            cell.textLabel.text = @"Hide SVG log messages";
            cell.textLabel.font = self.photogramCell.textLabel.font;
            cell.detailTextLabel.font = self.photogramCell.textLabel.font;
            [self setBooleanDetailText:cell value:[[PGLogger sharedInstance] hideSvgMessages]];
        } else if (kEnableExtraSocialSourcesIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"enableExtraSocialSources"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"enableExtraSocialSources"];
            }

            if ([[PGSocialSourcesManager sharedInstance] isEnabledExtraSocialSources]) {
                cell.textLabel.text = @"Disable extra social sources";
            } else {
                cell.textLabel.text = @"Enable extra social sources";
            }
            cell.textLabel.font = self.photogramCell.textLabel.font;
            cell.detailTextLabel.font = self.photogramCell.textLabel.font;
            cell.detailTextLabel.text = @"App restart is required";
        } else if (kEnablePushNotificationsIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"enablePushNotifications"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"enablePushNotifications"];
            }
            
            cell.textLabel.text = @"Enable push notifications";
        } else if (kDisplayNotificationMsgCenterIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"displayNotificationMsgCenter"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"displayNotificationMsgCenter"];
            }
            
            cell.textLabel.text = @"Display Notification Message Center";
        } else if (kEnableWatermarkIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"enableWatermark"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"enableWatermark"];
            }
            cell.textLabel.text = @"Watermark Enabled";
            cell.textLabel.font = self.photogramCell.textLabel.font;
            cell.detailTextLabel.font = self.photogramCell.textLabel.font;
            [self setBooleanDetailText:cell value:[PGLinkSettings linkEnabled]];
        } else if (kEnableVideoPrintIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"enableVideoPrint"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"enableVideoPrint"];
            }
            cell.textLabel.text = @"Video Print Enabled";
            cell.textLabel.font = self.photogramCell.textLabel.font;
            cell.detailTextLabel.font = self.photogramCell.textLabel.font;
            [self setBooleanDetailText:cell value:[PGLinkSettings videoPrintEnabled]];
        } else if (kEnableFakePrintIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"enableFakePrint"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"enableFakePrint"];
            }
            cell.textLabel.text = @"Fake Print Enabled";
            cell.textLabel.font = self.photogramCell.textLabel.font;
            cell.detailTextLabel.font = self.photogramCell.textLabel.font;
            [self setBooleanDetailText:cell value:[PGLinkSettings fakePrintEnabled]];
        } else if (kEnableLocalWatermarkIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"enableLocalWatermark"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"enableLocalWatermark"];
            }
            cell.textLabel.text = @"Enable Local Watermark";
            cell.textLabel.font = self.photogramCell.textLabel.font;
            cell.detailTextLabel.font = self.photogramCell.textLabel.font;
            [self setBooleanDetailText:cell value:[PGLinkSettings localWatermarkEnabled]];
        } else if(kEnableVideoAR == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"enableVideoAR"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"enableVideoAR"];
            }
            cell.textLabel.text = @"Enable Video AR";
            cell.textLabel.font = self.photogramCell.textLabel.font;
            cell.detailTextLabel.font = self.photogramCell.textLabel.font;
            [self setBooleanDetailText:cell value:[PGLinkSettings videoAREnabled]];
        } else if(kEnableVideoARParticles == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"enableVideoARParticles"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"enableVideoARParticles"];
            }
            cell.textLabel.text = @"Enable AR Video Particles";
            cell.textLabel.font = self.photogramCell.textLabel.font;
            cell.detailTextLabel.font = self.photogramCell.textLabel.font;
            [self setBooleanDetailText:cell value:[PGLinkSettings videoARParticlesEnabled]];
        } else if (kForceUpgradeIndex == selectedRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"forceUpgrade"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"forceUpgrade"];
            }
            cell.textLabel.font = self.photogramCell.textLabel.font;
            cell.textLabel.text = @"Force Firmware Upgrade";
            cell.detailTextLabel.font = self.photogramCell.textLabel.font;
            [self setBooleanDetailText:cell value:[[MP sharedInstance] forceFirmwareUpdates]];
        }
        
         cell.hidden = ![self enableFeature:selectedRow forCode:self.unlockCode];
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    if ([self levelPickerIsShown] && (self.pickerIndexPath.row - 1 == indexPath.row)) {
        [self hideExistingPicker];

    } else {
        if ([self.tableView cellForRowAtIndexPath:indexPath] == self.photogramCell ||
            [self.tableView cellForRowAtIndexPath:indexPath] == self.svgCell) {
            
            NSIndexPath *newPickerIndexPath = [self calculateIndexPathForNewPicker:indexPath];
            
            if ([self levelPickerIsShown]) {
                [self hideExistingPicker];
            }
            
            [self showNewPickerAtIndex:newPickerIndexPath];
            
            self.pickerIndexPath = [NSIndexPath indexPathForRow:newPickerIndexPath.row + 1 inSection:0];
        } else {
            NSInteger selectedRow = indexPath.row;
            if ([self levelPickerIsShown]) {
                selectedRow--;
                [self hideExistingPicker];
            }
            
            if (kMailLogsCellIndex == selectedRow) {
                [self composeEmailWithDebugAttachment];
            } else if (kClearLogsCellIndex == selectedRow) {
                [self clearLogfile];
            } else if(kTestLogsCellIndex == selectedRow) {
                [PGLogFormatter demoAllFormats];
            } else if (kCrashAppCellIndex == selectedRow) {
                [[Crashlytics sharedInstance] crash];
            } else if (kExceptionAppCellIndex == selectedRow) {
                [[PGAnalyticsManager sharedManager] fireTestException];
            } else if (kHideSvgMessagesIndex == selectedRow) {
                BOOL currentSetting = [[PGLogger sharedInstance] hideSvgMessages];
                [[PGLogger sharedInstance] setHideSvgMessages: !currentSetting];
                [self setBooleanDetailText:[tableView cellForRowAtIndexPath:indexPath] value:[[PGLogger sharedInstance] hideSvgMessages]];
            } else if (kEnableExtraSocialSourcesIndex == selectedRow) {
                [[PGSocialSourcesManager sharedInstance] toggleExtraSocialSourcesEnabled];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else if (kEnablePushNotificationsIndex == selectedRow) {
                [self enablePushNotifications];
            } else if (kDisplayNotificationMsgCenterIndex == selectedRow) {
                // Note-- you must enable messaging before this will work
                [[UAirship defaultMessageCenter] display];
            } else if (kEnableWatermarkIndex == selectedRow) {
                [PGLinkSettings setLinkEnabled:![PGLinkSettings linkEnabled]];
                [self setBooleanDetailText:[tableView cellForRowAtIndexPath:indexPath] value:[PGLinkSettings linkEnabled]];
            } else if( kEnableVideoPrintIndex == selectedRow) {
                [PGLinkSettings setVideoPrintEnabled:![PGLinkSettings videoPrintEnabled]];
                [self setBooleanDetailText:[tableView cellForRowAtIndexPath:indexPath] value:[PGLinkSettings videoPrintEnabled]];
            } else if( kEnableFakePrintIndex == selectedRow) {
                [PGLinkSettings setFakePrintEnabled:![PGLinkSettings fakePrintEnabled]];
                [self setBooleanDetailText:[tableView cellForRowAtIndexPath:indexPath] value:[PGLinkSettings fakePrintEnabled]];
            } else if( kEnableLocalWatermarkIndex == selectedRow) {
                [PGLinkSettings setLocalWatermarkEnabled:![PGLinkSettings localWatermarkEnabled]];
                [self setBooleanDetailText:[tableView cellForRowAtIndexPath:indexPath] value:[PGLinkSettings localWatermarkEnabled]];
            } else if( kEnableVideoAR == selectedRow) {
                [PGLinkSettings setVideoAREnabled:![PGLinkSettings videoAREnabled]];
                [self setBooleanDetailText:[tableView cellForRowAtIndexPath:indexPath] value:[PGLinkSettings videoAREnabled]];
            } else if( kEnableVideoARParticles == selectedRow) {
                [PGLinkSettings setVideoARParticlesEnabled:![PGLinkSettings videoARParticlesEnabled]];
                [self setBooleanDetailText:[tableView cellForRowAtIndexPath:indexPath] value:[PGLinkSettings videoARParticlesEnabled]];
            } else if (kForceUpgradeIndex == selectedRow) {
                BOOL force = ![[MP sharedInstance] forceFirmwareUpdates];
                
                [[NSUserDefaults standardUserDefaults] setBool:force forKey:kPGSettingsForceFirmwareUpgrade];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [[MP sharedInstance] setForceFirmwareUpdates:force];
                [self.tableView reloadData];
            }
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // Make the correct selection in the picker view
    if( [self levelPickerIsShown] ) {
        if( [tableView cellForRowAtIndexPath:indexPath] == self.photogramCell ) {
            [self.pickerView selectRow:[self rowForLogLevel:pgLogLevel] inComponent:0 animated:NO];
        }
        else {
            [self.pickerView selectRow:[self rowForLogLevel:(ddLogLevel << PG_LOG_SHIFT)] inComponent:0 animated:NO];
        }
    }
}


#pragma mark - Mailing Logfile

- (void)enablePushNotifications {
    // User notifications will not be enabled until userPushNotificationsEnabled is
    // set YES on UAPush. Onced enabled, the setting will be persisted and the user
    // will be prompted to allow notifications. You should wait for a more appropriate
    // time to enable push to increase the likelihood that the user will accept
    // notifications. For troubleshooting, we will enable this at launch.
    [UAirship push].userPushNotificationsEnabled = YES;
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Notifications Enabled" message:@"Urban Airship notifications enabled.  Your Urban Airship channel ID is in the text field.  Perform a long tap, Select All, and Copy to copy the ID:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].text = [NSString stringWithFormat: @"%@", [UAirship push].channelID];
    [av textFieldAtIndex:0].delegate = nil;
    [av show];
}

- (void)clearLogfile
{
    PGLogger* logger = (PGLogger *)[PGLogger sharedInstance];

    NSArray *sortedLogFileInfos = [logger.fileLogger.logFileManager sortedLogFileInfos];
    for( DDLogFileInfo *logFileInfo in sortedLogFileInfos ) {
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:logFileInfo.filePath];
        [file truncateFileAtOffset:0];
        [file closeFile];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil)
                                                    message:NSLocalizedString(@"Log file has been cleared.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)composeEmailWithDebugAttachment
{
    if ([MFMailComposeViewController canSendMail]) {
        PGLogger* logger = (PGLogger *)[PGLogger sharedInstance];
        
        [logger cycleMailComposer];
        MFMailComposeViewController *mailViewController = [logger globalMailComposer];
        mailViewController.mailComposeDelegate = self;
        
        NSMutableData *errorLogData = [NSMutableData data];
        for (NSData *errorLogFileData in [logger errorLogData]) {
            [errorLogData appendData:errorLogFileData];
        }
        [mailViewController addAttachmentData:errorLogData mimeType:@"text/plain" fileName:@"errorLog.txt"];
        [mailViewController setSubject:NSLocalizedString(@"sprocket error log", nil)];
        [mailViewController setMessageBody:NSLocalizedString(@"The logfile is attached to this message.", nil) isHTML:NO];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
        
    }
    
    else {
        NSString *message = NSLocalizedString(@"Sorry, your issue can’t be reported right now. This is most likely because no mail accounts are set up on your mobile device.", nil);
        [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    if( MFMailComposeResultCancelled == result ) {
        PGLogWarn(@"If you didn't cancel that message on purpose, you're probably trying to run the Mail Composer on the simulator.\n\nIt doesn't work on the simulator.");
    }
    else if( MFMailComposeResultFailed == result ) {
        PGLogError(@"Ack!  Your message failed to be sent.  I blame you.  Here's the result: %ld, and error: %@", (long)result, error);
    }
    else {
        PGLogVerbose(@"Mail Composer closed gracefully with result: %ld, error: %@", (long)result, error);
    }
    
    PGLogger* logger = (PGLogger *)[PGLogger sharedInstance];
    MFMailComposeViewController *mailViewController = [logger globalMailComposer];
    [mailViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Picker DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}


#pragma mark - Picker Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    NSInteger logLevel = [self logLevelForRow:row];
    
    return [self stringForLogLevel:logLevel];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{

    NSIndexPath *logTypeCellPath = [NSIndexPath indexPathForRow:self.pickerIndexPath.row - 1 inSection:0];
    UITableViewCell *logTypeCell = [self.tableView cellForRowAtIndexPath:logTypeCellPath];
    
    if( logTypeCell == self.photogramCell ) {
        NSInteger logLevel = [self logLevelForRow:row];
        self.photogramCell.detailTextLabel.text = [self stringForLogLevel:logLevel];
        [[PGLogger sharedInstance]setPgLogLevel:logLevel];
    } else if( logTypeCell == self.svgCell ) {
        NSInteger logLevel = [self logLevelForRow:row];
        self.svgCell.detailTextLabel.text = [self stringForLogLevel:logLevel];
        [[PGLogger sharedInstance]setDdLogLevel:(logLevel >> PG_LOG_SHIFT)];
    }
    
    [self.tableView beginUpdates];
        [self hideExistingPicker];
    [self.tableView endUpdates];
}

- (NSInteger)logLevelForRow:(NSInteger)row
{
    NSInteger logLevel;
    
    switch (row) {
        case 0:
            logLevel = PGLogLevelError;
            break;
            
        case 1:
            logLevel = PGLogLevelWarning;
            break;
            
        case 2:
            logLevel = PGLogLevelInfo;
            break;
            
        case 3:
            logLevel = PGLogLevelDebug;
            break;
            
        case 4:
            logLevel = PGLogLevelVerbose;
            break;
            
        default:
            break;
    }

    return logLevel;
}

- (NSInteger)rowForLogLevel:(NSInteger)logLevel
{
    NSInteger row;
    
    switch (logLevel) {
        case PGLogLevelError:
            row = 0;
            break;
            
        case PGLogLevelWarning:
            row = 1;
            break;
            
        case PGLogLevelInfo:
            row = 2;
            break;
            
        case PGLogLevelDebug:
            row = 3;
            break;
            
        case PGLogLevelVerbose:
            row = 4;
            break;
            
        default:
            break;
    }
    
    return row;
}

- (NSString*)stringForLogLevel:(NSInteger)logLevel
{
    NSString *strLevel = @"Unknown";
    
    switch (logLevel) {
        case PGLogLevelError:
            strLevel = kErrorString;
            break;
            
        case PGLogLevelWarning:
            strLevel = kWarnString;
            break;

        case PGLogLevelInfo:
            strLevel = kInfoString;
            break;

        case PGLogLevelDebug:
            strLevel = kDebugString;
            break;

        case PGLogLevelVerbose:
            strLevel = kVerboseString;
            break;

        default:
            break;
    }
    
    return strLevel;
}

#pragma mark - Helpers

- (void)setBooleanDetailText:(UITableViewCell *)cell value:(BOOL)value
{
    if( value ) {
        cell.detailTextLabel.text = @"True";
    }
    else {
        cell.detailTextLabel.text = @"False";
    }
}

- (BOOL)validCode:(NSString *)code
{
    return [code isEqualToString:kFeatureCodeAll] || [code isEqualToString:kFeatureCodeLink];
}

- (BOOL)enableFeature:(NSInteger)index forCode:(NSString *)code
{
    BOOL enabled = NO;
    if ([code isEqualToString:kFeatureCodeAll]) {
        enabled = YES;
    } else if ([code isEqualToString:kFeatureCodeLink] && (kEnableWatermarkIndex == index || kEnableVideoPrintIndex == index || kEnableFakePrintIndex == index || kEnableLocalWatermarkIndex == index || kEnableVideoAR == index || kEnableVideoARParticles == index)) {
        enabled = YES;
    }
    return enabled;
}

@end
