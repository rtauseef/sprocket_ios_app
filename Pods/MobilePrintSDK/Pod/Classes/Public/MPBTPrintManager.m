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

static NSString * const kPrintManagerQueueIdKey = @"com.hp.mobile-print.bt.print-manager.queue-id";

@interface MPBTPrintManager () <MPBTSprocketDelegate>

@property (nonatomic, assign) NSInteger queueId;
@property (nonatomic, assign) NSInteger originalQueueSize;
@property (nonatomic, strong) NSString *printerId;

@property (nonatomic, strong) NSTimer *checkTimer;
@property (nonatomic, assign) MPBTPrinterManagerStatus status;
@property (nonatomic, strong) MPPrintLaterJob *currentJob;
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


- (void)addPrintItemToQueue:(MPPrintItem *)printItem {
    MPPrintLaterJob *job = [[MPPrintLaterJob alloc] init];
    job.id = [[MPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
    job.printItems = @{[MP sharedInstance].defaultPaper.sizeTitle: printItem};

    [[MPPrintLaterQueue sharedInstance] addPrintLaterJob:job fromController:nil];
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

- (void)cancelPrintQueue {
    self.status = MPBTPrinterManagerStatusEmptyQueue;

    [[MPPrintLaterQueue sharedInstance] deleteAllPrintLaterJobs];

    [self.checkTimer invalidate];
    self.checkTimer = nil;

    self.originalQueueSize = 0;
    self.printerId = nil;
    [self incrementQueueId];
}

- (void)pausePrintQueue {
    self.status = MPBTPrinterManagerStatusIdle;

    [self.checkTimer invalidate];
    self.checkTimer = nil;
}

- (NSInteger)queueSize {
    return [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
}

- (NSInteger)queueId {
    return [self currentQueueId];
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

- (void)checkPrinterStatus {
    EAAccessory *device = [MPBTSprocket sharedInstance].accessory;

    if (!device) {
        NSArray *pairedSprockets = [MPBTSprocket pairedSprockets];
        device = (EAAccessory *)[pairedSprockets firstObject];
    }

    if (device) {
        if (self.status != MPBTPrinterManagerStatusSendingPrintJob) {
            MPBTSprocket *sprocket = [MPBTSprocket sharedInstance];

            sprocket.accessory = device;
            sprocket.delegate = self;

            if (self.status = MPBTPrinterManagerStatusResumingPrintQueue) {
                self.printerId = [sprocket.analytics objectForKey:kMPPrinterId];
            }

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
    if (error == MantaErrorNoError) {
        self.status = MPBTPrinterManagerStatusSendingPrintJob;

        self.currentJob = [[[MPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs] lastObject];

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

            [self cancelPrintQueue];
        }

    } else {
        self.status = MPBTPrinterManagerStatusWaitingForPrinter;

        NSLog(@"PRINT QUEUE - NOT READY: %@", @(error));
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
    [[MPPrintLaterQueue sharedInstance] deletePrintLaterJob:self.currentJob];

    [self sendStatusUpdate:0];

    if ([self.delegate respondsToSelector:@selector(btPrintManager:didStartPrintingJob:)]) {
        [self.delegate btPrintManager:self didStartPrintingJob:self.currentJob];
    }

    self.currentJob = nil;
}

- (void)didReceiveError:(MPBTSprocket *)sprocket error:(MantaError)error {
    NSLog(@"PRINT QUEUE - ERROR (%@)", @(error));

    self.status = MPBTPrinterManagerStatusWaitingForPrinter;

    if (error == MantaErrorNoSession) {
        sprocket.accessory = nil;
    }

    if ([self.delegate respondsToSelector:@selector(btPrintManager:didReceiveErrorForPrintJob:)]) {
        [self.delegate btPrintManager:self didReceiveErrorForPrintJob:self.currentJob];
    }
}

@end
