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

#import "MPBTPrintManager.h"
#import "MPPaper.h"
#import "MPPrintLaterQueue.h"
#import "MPBTSprocket.h"
#import "MPAnalyticsManager.h"

static NSString * const kPrintManagerQueueIdKey = @"com.hp.mobile-print.bt.print-manager.queue-id";

@interface MPBTPrintManager () <MPBTSprocketDelegate>

@property (nonatomic, assign) NSInteger queueId;
@property (nonatomic, assign) NSInteger originalQueueSize;

@property (nonatomic, strong) NSTimer *checkTimer;
@property (nonatomic, strong) NSTimer *finalCheckTimer;
@property (nonatomic, assign) MPBTPrinterManagerStatus status;
@property (nonatomic, strong) MPPrintLaterJob *currentJob;
@property (nonatomic, strong) MPPrintLaterJob *directJob;
@property (nonatomic, copy) BOOL (^statusUpdateBlock)(MPBTPrinterManagerStatus status, NSInteger progress);

@end

@implementation MPBTPrintManager

+ (instancetype)sharedInstance {
    static MPBTPrintManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MPBTPrintManager alloc] init];
    });

    return instance;
}

- (MPPrintLaterJob *)jobForPrintItem:(MPPrintItem *)printItem metrics:(NSDictionary *)metrics {
    MPPrintLaterJob *job = [[MPPrintLaterJob alloc] init];
    job.id = [[MPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
    job.printItems = @{[MP sharedInstance].defaultPaper.sizeTitle: printItem};
    [job prepareMetricsForOfframp:[metrics objectForKey:kMPOfframpKey]];

    NSMutableDictionary *finalMetrics = [NSMutableDictionary dictionaryWithDictionary:metrics];
    [finalMetrics addEntriesFromDictionary:[MP sharedInstance].lastOptionsUsed];
    [finalMetrics addEntriesFromDictionary:job.extra];

    job.extra = finalMetrics;

    return job;
}

- (BOOL)printDirect:(MPPrintItem *)printItem metrics:(NSDictionary *)metrics statusUpdate:(BOOL (^)(MPBTPrinterManagerStatus, NSInteger))statusUpdate {
    if (self.status != MPBTPrinterManagerStatusEmptyQueue) {
        [self reportError:MantaErrorBusy isFinalError:NO];
        return NO;
    }

    self.statusUpdateBlock = statusUpdate;

    self.directJob = [self jobForPrintItem:printItem metrics:metrics];

    self.status = MPBTPrinterManagerStatusResumingPrintQueue;

    [self checkPrinterStatus];
    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkPrinterStatus) userInfo:nil repeats:YES];
}

- (BOOL)addPrintItemToQueue:(MPPrintItem *)printItem metrics:(NSDictionary *)metrics {
    if (self.status != MPBTPrinterManagerStatusEmptyQueue) {
        [self reportError:MantaErrorBusy isFinalError:NO];
        return NO;
    }

    MPPrintLaterJob *job = [self jobForPrintItem:printItem metrics:metrics];

    [[MPPrintLaterQueue sharedInstance] addPrintLaterJob:job fromController:nil];

    return YES;
}

- (void)resumePrintQueue:(BOOL (^)(MPBTPrinterManagerStatus, NSInteger))statusUpdate {
    [self.checkTimer invalidate];

    self.statusUpdateBlock = statusUpdate;

    NSInteger queueSize = [self queueSize];
    if (queueSize > 0) {
        self.originalQueueSize = queueSize;

        self.status = MPBTPrinterManagerStatusResumingPrintQueue;

        [self checkPrinterStatus];
        self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkPrinterStatus) userInfo:nil repeats:YES];
    }
}

- (void)clearPrintQueue {
    self.status = MPBTPrinterManagerStatusEmptyQueue;

    [self.checkTimer invalidate];
    self.checkTimer = nil;

    self.originalQueueSize = 0;
    [self incrementQueueId];
}

- (void)cancelPrintQueue {
    self.status = MPBTPrinterManagerStatusEmptyQueue;

    [[MPPrintLaterQueue sharedInstance] deleteEachPrintLaterJobsWithBlock:^(MPPrintLaterJob *job) {
        if ([self.delegate respondsToSelector:@selector(mtPrintManager:didDeletePrintJob:)]) {
            [self.delegate mtPrintManager:self didDeletePrintJob:job];
        }
    }];

    [self clearPrintQueue];

    if ([self.delegate respondsToSelector:@selector(btPrintManagerDidClearPrintQueue:)]) {
        [self.delegate btPrintManagerDidClearPrintQueue:self];
    }
}

- (void)pausePrintQueue {
    self.status = MPBTPrinterManagerStatusIdle;

    [self sendStatusUpdate:0];

    [self.checkTimer invalidate];
    self.checkTimer = nil;
}

- (NSInteger)queueSize {
    return [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
}

- (NSInteger)queueId {
    return [self currentQueueId];
}

- (NSDictionary *)printerAnalytics {
    return [MPBTSprocket sharedInstance].analytics;
}

- (NSString *)printerId {
    return [[MPBTSprocket sharedInstance].analytics objectForKey:kMPPrinterId];
}

- (NSInteger)currentQueueId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSInteger queueId = [userDefaults integerForKey:kPrintManagerQueueIdKey];

    if (queueId == 0) {
        // It's the first queue sent to printer
        queueId = [self incrementQueueId];
    }

    return queueId;
}

- (NSInteger)incrementQueueId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger queueId = [userDefaults integerForKey:kPrintManagerQueueIdKey];

    queueId++;

    [userDefaults setInteger:queueId forKey:kPrintManagerQueueIdKey];
    [userDefaults synchronize];
}

- (EAAccessory *)currentDevice
{
    EAAccessory *device = [MPBTSprocket sharedInstance].accessory;

    if (!device) {
        NSArray *pairedSprockets = [MPBTSprocket pairedSprockets];
        device = (EAAccessory *)[pairedSprockets firstObject];
    }
    
    return device;
}

- (void)checkForFinalError {
    EAAccessory *device = [self currentDevice];
    
    if (device) {
        MPBTSprocket *sprocket = [MPBTSprocket sharedInstance];
        
        sprocket.accessory = device;
        sprocket.delegate = self;
        
        [sprocket refreshInfo];
    }
}

- (void)checkPrinterStatus {
    EAAccessory *device = [self currentDevice];
    
    if (device) {
        if (self.status != MPBTPrinterManagerStatusSendingPrintJob) {
            MPBTSprocket *sprocket = [MPBTSprocket sharedInstance];

            sprocket.accessory = device;
            sprocket.delegate = self;

            [self sendStatusUpdate:0];

            [sprocket refreshInfo];

        } else {
            NSLog(@"PRINT QUEUE - WAITING FOR JOB TO START (%@)", self.currentJob.id);

            static int numberOfTries = 0;

            if (numberOfTries < 3) {
                numberOfTries++;
            } else {
                numberOfTries = 0;
                self.status = MPBTPrinterManagerStatusIdle;
            }
        }

    } else {
        NSLog(@"PRINT QUEUE - NO DEVICES CONNECTED");
    }
}

- (void)sendStatusUpdate:(NSInteger)progress {
    if (self.statusUpdateBlock) {
        BOOL shouldContinueUpdatingStatus = self.statusUpdateBlock(self.status, progress);

        if (!shouldContinueUpdatingStatus) {
            self.statusUpdateBlock = nil;
        }
    }
}


#pragma mark - MPBTSprocketDelegate

- (void)didRefreshMantaInfo:(MPBTSprocket *)sprocket error:(MantaError)error {
    if (self.finalCheckTimer) {
        NSLog(@"Handling final error");
        // We're waiting for the device to stop printing in order to gather the final error, if any
        if (MantaErrorBusy != error) {
            [self.finalCheckTimer invalidate];
            self.finalCheckTimer = nil;
            if (MantaErrorNoError != error) {
                [self reportError:error isFinalError:YES];
            }
        }
    } else if (error == MantaErrorNoError) {
        self.status = MPBTPrinterManagerStatusSendingPrintJob;

        if (self.directJob) {
            self.currentJob = self.directJob;
        } else {
            self.currentJob = [[[MPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs] lastObject];
        }

        if (self.currentJob) {
            NSLog(@"PRINT QUEUE - SENDING JOB (%@)", self.currentJob.id);

            NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionaryWithDictionary:[MP sharedInstance].lastOptionsUsed];
            [lastOptionsUsed addEntriesFromDictionary:[MPBTSprocket sharedInstance].analytics];
            [MP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];

            MPPrintItem *item = [self.currentJob defaultPrintItem];

            if (item) {
                if ([self.delegate respondsToSelector:@selector(btPrintManager:didStartSendingPrintJob:)]) {
                    [self.delegate btPrintManager:self didStartSendingPrintJob:self.currentJob];
                }

                [sprocket printItem:item numCopies:1];
            } else {
                NSLog(@"PRINT QUEUE - NO IMAGE FOR JOB (%@)", self.currentJob.id);
            }

        } else {
            NSLog(@"PRINT QUEUE - EMPTY");

            [self clearPrintQueue];
        }

    } else {
        self.status = MPBTPrinterManagerStatusWaitingForPrinter;

        NSLog(@"PRINT QUEUE - NOT READY: %@", @(error));

        if (error != MantaErrorBusy) {
            [self reportError:error isFinalError:NO];
        }
    }
}

- (void)didSendPrintData:(MPBTSprocket *)sprocket percentageComplete:(NSInteger)percentageComplete error:(MantaError)error {
    NSLog(@"PRINT QUEUE - SENDING DATA %li (%@)", (long)percentageComplete, self.currentJob.id);

    [self sendStatusUpdate:percentageComplete];

    if ([self.delegate respondsToSelector:@selector(btPrintManager:sendingPrintJob:progress:)]) {
        [self.delegate btPrintManager:self sendingPrintJob:self.currentJob progress:percentageComplete];
    }
}

- (void)didFinishSendingPrint:(MPBTSprocket *)sprocket {
    NSLog(@"PRINT QUEUE - JOB SENT TO PRINTER (%@)", self.currentJob.id);

    if ([self.delegate respondsToSelector:@selector(btPrintManager:didFinishSendingPrintJob:)]) {
        [self.delegate btPrintManager:self didFinishSendingPrintJob:self.currentJob];
    }
}

- (void)didStartPrinting:(MPBTSprocket *)sprocket {
    NSLog(@"PRINT QUEUE - JOB STARTED PRINTING (%@)", self.currentJob.id);

    self.status = MPBTPrinterManagerStatusPrinting;
    [self sendStatusUpdate:0];

    if (self.directJob) {
        self.directJob = nil;

        if ([self.delegate respondsToSelector:@selector(btPrintManager:didStartPrintingDirectJob:)]) {
            [self.delegate btPrintManager:self didStartPrintingDirectJob:self.currentJob];
        }
    } else {
        [[MPPrintLaterQueue sharedInstance] completePrintLaterJob:self.currentJob];

        if ([self.delegate respondsToSelector:@selector(btPrintManager:didStartPrintingJob:)]) {
            [self.delegate btPrintManager:self didStartPrintingJob:self.currentJob];
        }
    }

    if ([self queueSize] == 0) {
        NSLog(@"PRINT QUEUE - EMPTY");

        [self clearPrintQueue];
        
        // look for any post print error states on the device (like "Wrong Paper Type")
        self.finalCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkForFinalError) userInfo:nil repeats:YES];
    }

    self.currentJob = nil;
}

- (void)didReceiveError:(MPBTSprocket *)sprocket error:(MantaError)error {
    NSLog(@"PRINT QUEUE - ERROR (%@)", @(error));

    if (self.status != MPBTPrinterManagerStatusEmptyQueue) {
        self.status = MPBTPrinterManagerStatusWaitingForPrinter;
    }

    if (error == MantaErrorNoSession) {
        sprocket.accessory = nil;
    }

    [self reportError:error isFinalError:NO];
}

- (void)reportError:(MantaError)error isFinalError:(BOOL)isFinalError {
    if (self.status == MPBTPrinterManagerStatusEmptyQueue  &&  !isFinalError) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(btPrintManager:didReceiveError:forPrintJob:)]) {
        [self.delegate btPrintManager:self didReceiveError:error forPrintJob:self.currentJob];
    }
}

@end
