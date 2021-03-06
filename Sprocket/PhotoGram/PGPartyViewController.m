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

#import "PGPartyViewController.h"
#import "PGPartyHostManager.h"
#import "PGPartyGuestManager.h"
#import "PGSavePhotos.h"
#import <Photos/Photos.h>
#import "PGAnalyticsManager.h"
#import "PGPrintQueueManager.h"
#import "PGInAppMessageManager.h"
#import "PGFeatureFlag.h"
#import "PGAppNavigation.h"

#import <HPPRSelectPhotoCollectionViewController.h>
#import <MPPrintItemFactory.h>
#import <MPBTPrintManager.h>

@interface PGPartyViewController () <PGPartyHostManagerDelegate, PGPartyGuestManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *hostButton;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation PGPartyViewController

static NSTimeInterval const kAnimationDuration = 0.2;

// TODO: jbt: fix duplicate key between this class and PGPreviewViewController
static NSString * const kPrinterConnected = @"printer_connected";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [PGPartyHostManager sharedInstance].delegate = self;
    [PGPartyGuestManager sharedInstance].delegate = self;
}

#pragma mark - Event Handlers

- (IBAction)sendButtonTapped:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)hostButtonTapped:(id)sender {
    [self hostingUI];
    [PGPartyHostManager sharedInstance].scanning = YES;
}

- (IBAction)joinButtonTapped:(id)sender {
    [self waitingToJoinUI];
    [PGPartyGuestManager sharedInstance].advertising = YES;
}
- (IBAction)stopButtonTapped:(id)sender {
    [self stopUI];
    [PGPartyHostManager sharedInstance].scanning = NO;
    [PGPartyGuestManager sharedInstance].advertising = NO;
}

- (IBAction)touchedDownInButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];
}

- (IBAction)touchedUpInButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor clearColor];
}

#pragma mark - UI

- (void)setupUI
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        self.sendButton.layer.cornerRadius = 3.0;
        self.sendButton.layer.borderColor  = [UIColor whiteColor].CGColor;
        self.sendButton.layer.borderWidth = 1.0;
        self.sendButton.layer.masksToBounds = YES;
        
        self.hostButton.layer.cornerRadius = 3.0;
        self.hostButton.layer.borderColor  = [UIColor whiteColor].CGColor;
        self.hostButton.layer.borderWidth = 1.0;
        self.hostButton.layer.masksToBounds = YES;
        
        self.joinButton.layer.cornerRadius = 3.0;
        self.joinButton.layer.borderColor  = [UIColor whiteColor].CGColor;
        self.joinButton.layer.borderWidth = 1.0;
        self.joinButton.layer.masksToBounds = YES;
        
        self.stopButton.layer.cornerRadius = 3.0;
        self.stopButton.layer.borderColor  = [UIColor whiteColor].CGColor;
        self.stopButton.layer.borderWidth = 1.0;
        self.stopButton.layer.masksToBounds = YES;
//    });
    
    if ([PGPartyHostManager sharedInstance].scanning) {
        [self hostingUI];
        [self updateConnectedCount];
    } else if([PGPartyGuestManager sharedInstance].advertising) {
        if ([PGPartyGuestManager sharedInstance].connected) {
            [self joinedUI];
        } else {
            [self waitingToJoinUI];
        }
    } else {
        [self stopUI];
    }
}

- (void)hostingUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.hostButton.hidden = YES;
            self.joinButton.hidden = YES;
            self.stopButton.hidden = NO;
            self.sendButton.hidden = YES;
            self.statusLabel.hidden = NO;
            self.progressView.hidden = YES;
            self.statusLabel.text = [self connectionText];
        }];
    });
}

- (void)waitingToJoinUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.hostButton.hidden = YES;
            self.joinButton.hidden = YES;
            self.stopButton.hidden = NO;
            self.sendButton.hidden = YES;
            self.statusLabel.hidden = NO;
            self.progressView.hidden = YES;
            self.statusLabel.text = NSLocalizedString(@"Waiting for a party...", @"Waiting for party host to start a party");
        }];
    });
}

- (void)joinedUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.hostButton.hidden = YES;
            self.joinButton.hidden = YES;
            self.stopButton.hidden = NO;
            self.sendButton.hidden = NO;
            self.statusLabel.hidden = NO;
            self.progressView.hidden = YES;
            self.statusLabel.text = NSLocalizedString(@"Connected", @"Party is connected");
        }];
    });
}

- (void)stopUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.hostButton.hidden = NO;
            self.joinButton.hidden = NO;
            self.stopButton.hidden = YES;
            self.sendButton.hidden = YES;
            self.statusLabel.hidden = YES;
            self.progressView.hidden = YES;
        }];
    });
}

- (void)updateConnectedCount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = [self connectionText];
    });
}

- (void)updateProgress:(float)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (progress > self.progressView.progress) {
            self.progressView.progress = progress;
        }
        self.progressView.hidden = NO;
    });
}

- (void)hideProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = 0;
        self.progressView.hidden = YES;
    });
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Okay") style:UIAlertActionStyleDefault handler:nil]];
    [[PGAppNavigation currentTopViewController] presentViewController:alert animated:YES completion:nil];
}

- (NSString *)connectionText
{
    NSUInteger count = [PGPartyHostManager sharedInstance].connectedDevices.count;
    NSString *text = NSLocalizedString(@"Waiting for connections...", @"Host is waiting for guests to connect");
    if (1 == count) {
        text = NSLocalizedString(@"1 connected device", @"Indicates that 1 device is connected");
    } else if (count > 1) {
        text = [NSString stringWithFormat:NSLocalizedString(@"%lu connected devices", @"Indicates that multiple devices are connected"), (unsigned long)count];
    }
    return text;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    PGLogDebug(@"IMAGE PICKER: SELECTED PHOTO %@", image);
    [self dismissViewControllerAnimated:YES completion:^{
        [self updateProgress:0];
        [[PGPartyGuestManager sharedInstance] sendImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PGPartyHostManagerDelegate

- (void)partyHostManagerDidStartScanning
{
    PGLogDebug(@"HOST DELEGATE: SCANNING ON");
}

- (void)partyHostManagerDidStopScanning
{
    PGLogDebug(@"HOST DELEGATE: SCANNING OFF");
    [self stopUI];
}

- (void)partyHostManagerScanningError:(NSError *)error
{
    PGLogDebug(@"HOST DELEGATE: SCANNING ERROR: %@", error);
    [self alertWithTitle:@"Hosting Error" message:error.localizedDescription];
}

- (void)partyHostManagerDidConnectPeripheral:(NSDictionary *)peripheral
{
    PGLogDebug(@"HOST DELEGATE: CONNECTED PERIPHERAL: %@", peripheral);
    [self updateConnectedCount];
}

- (void)partyHostManagerDidDisconnectPeripheral:(NSDictionary *)peripheral error:(NSError *)error
{
    PGLogDebug(@"HOST DELEGATE: DISCONNECTED PERIPHERAL: %@: %@", peripheral, error);
    [self updateConnectedCount];
}

- (void)partyHostManagerPeripheralError:(NSDictionary *)peripheral error:(NSError *)error
{
    PGLogDebug(@"HOST DELEGATE: PERIPHERAL ERROR: %@: %@", peripheral, error);
    [self updateConnectedCount];
}

- (void)partyHostManagerReceivedImage:(UIImage *)image fromPeripheral:(NSDictionary *)peripheral
{
    PGLogDebug(@"HOST DELEGATE: RECEIVED IMAGE: %@", [peripheral objectForKey:kPGPartyManagerPeripheralIdentifierKey]);
    [self handleImageComplete:image];
}

- (void)partyHostManagerUploadProgress:(CGFloat)progress identifier:(NSUInteger)identifier
{
    PGLogDebug(@"HOST DELEGATE: UPLOAD: PROGRESS: %lu: %.5f", (unsigned long)identifier, progress);
}

- (void)partyHostManagerDownloadProgress:(CGFloat)progress identifier:(NSUInteger)identifier
{
    PGLogDebug(@"HOST DELEGATE: DOWNLOAD: PROGRESS: %lu: %.5f", (unsigned long)identifier, progress);
}

#pragma mark - PGPartyGuestManagerDelegate

- (void)partyGuestManagerDidStartAdvertising
{
    PGLogDebug(@"GUEST DELEGATE: ADVERTISING ON");
}

- (void)partyGuestManagerDidStopAdvertising
{
    PGLogDebug(@"GUEST DELEGATE: ADVERTISING OFF");
    [self stopUI];
}

- (void)partyGuestManagerAdvertisingError:(NSError *)error
{
    PGLogDebug(@"GUEST DELEGATE: ADVERTISING ERROR: %@", error);
    [self alertWithTitle:@"Scanning Error" message:error.localizedDescription];
}

- (void)partyGuestManagerDidConnectCentral
{
    PGLogDebug(@"GUEST DELEGATE: CONNECTED CENTRAL");
    [self joinedUI];
}

- (void)partyGuestManagerDidDisconnectCentral
{
    PGLogDebug(@"GUEST DELEGATE: CONNECTED CENTRAL");
    [self waitingToJoinUI];
}

- (void)partyGuestManagerHostReceivedImage:(UIImage *)image
{
    PGLogDebug(@"GUEST DELEGATE: HOST RECEIVED: %@", image);
    [self hideProgress];
}

- (void)partyGuestManagerUploadProgress:(float)progress
{
    PGLogDebug(@"GUEST DELEGATE: UPLOAD: PROGRESS: %.5f", progress);
    [self updateProgress:0.5 * progress];
}

- (void)partyGuestManagerDownloadProgress:(float)progress
{
    PGLogDebug(@"GUEST DELEGATE: DOWNLOAD: PROGRESS: %.5f", progress);
    [self updateProgress:0.5 + 0.5 * progress];
}

#pragma mark - Image

- (void)handleImageComplete:(UIImage *)image
{
    [[PGInAppMessageManager sharedInstance] showPartyPhotoReceivedMessage];

    if ([PGFeatureFlag isPartySaveEnabled]) {
        [PGSavePhotos saveImage:image album:kPGSavePhotosSprocketPartyAlbum completion:^(BOOL success, PHAsset *asset) {
            if (success) {
                PGLogDebug(@"PHOTO SAVED!");
                [[NSNotificationCenter defaultCenter] postNotificationName:kHPPRSelectPhotoRefreshImagesNotification object:nil];
            } else {
                PGLogDebug(@"PHOTO SAVE ERROR");
            }
        }];
    }
    
    if ([PGFeatureFlag isPartyPrintEnabled]) {
        @synchronized ([MPBTPrintManager sharedInstance]) {
            MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:image];
            NSMutableDictionary *metrics = [[PGAnalyticsManager sharedManager] getMetrics:kMetricsOffRampQueueAddParty printItem:printItem extendedInfo:@{}];
            [metrics setObject:kMetricsOriginParty forKey:kMetricsOrigin];
            [metrics setObject:@([MPBTPrintManager sharedInstance].queueId) forKey:kMetricsPrintQueueIdKey];
            [metrics setObject:@(1) forKey:kMetricsPrintQueueCopiesKey];
            // TODO: jbt: fix printer connected value
            [metrics setObject:@{kPrinterConnected:[[NSNumber numberWithBool:NO] stringValue]} forKey:kMPCustomAnalyticsKey];
            [[MPBTPrintManager sharedInstance] addPrintItemToQueue:printItem metrics:metrics];
            [[PGAnalyticsManager sharedManager] postMetricsWithOfframp:kMetricsOffRampQueueAddParty
                                                             printItem:printItem
                                                          extendedInfo:metrics];
            
            MPBTPrinterManagerStatus printerStatus = [MPBTPrintManager sharedInstance].status;
            BOOL isPrinting = printerStatus != MPBTPrinterManagerStatusEmptyQueue && printerStatus != MPBTPrinterManagerStatusIdle;
            if (!isPrinting) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[MPBTPrintManager sharedInstance] resumePrintQueue:nil];
                });
            }
        }
    }
}

@end
