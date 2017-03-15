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
#import "MPBTSprocket.h"
#import "MPPaper.h"
#import "MPPrintLaterJob.h"
#import "MPPrintLaterQueue.h"

@interface MPBTPrintManager () <MPBTSprocketDelegate>

@property (nonatomic, strong) NSTimer *checkTimer;
@property (nonatomic, assign) MPBTPrinterManagerStatus status;
@property (nonatomic, strong) MPPrintLaterJob *currentJob;

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
//    MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:image];
//    printItem.extra = @{kMultiPrintOfframpKey: @"PrintFromMultiSelect"};

    MPPrintLaterJob *job = [[MPPrintLaterJob alloc] init];
    job.id = [[MPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
    job.printItems = @{[MPPaper titleFromSize:MPPaperSize2x3]: printItem};

    [[MPPrintLaterQueue sharedInstance] addPrintLaterJob:job fromController:nil];
}

- (void)resumePrintQueue {
    [self.checkTimer invalidate];

    if ([self queueSize] > 0) {
        [self checkPrinterStatus];
        self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(checkPrinterStatus) userInfo:nil repeats:YES];
    }
}

- (void)cancelPrintQueue {
    self.status = MPBTPrinterManagerStatusEmptyQueue;

    [[MPPrintLaterQueue sharedInstance] deleteAllPrintLaterJobs];

    [self.checkTimer invalidate];
    self.checkTimer = nil;
}

- (void)pausePrintQueue {
    self.status = MPBTPrinterManagerStatusIdle;

    [self.checkTimer invalidate];
    self.checkTimer = nil;
}

- (NSInteger)queueSize {
    return [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
}


- (void)checkPrinterStatus {
    NSArray *pairedSprockets = [MPBTSprocket pairedSprockets];

    EAAccessory *device = (EAAccessory *)[pairedSprockets firstObject];

    if (device) {
        MPBTSprocket *sprocket = [MPBTSprocket sharedInstance];

        sprocket.accessory = device;
        sprocket.delegate = self;

        [sprocket refreshInfo];
    } else {
        NSLog(@"PRINT QUEUE - NO DEVICES CONNECTED");
    }
}

#pragma mark - MPBTSprocketDelegate

- (void)didRefreshMantaInfo:(MPBTSprocket *)sprocket error:(MantaError)error {
    if (error == MantaErrorNoError) {
        self.status = MPBTPrinterManagerStatusPrinting;

        self.currentJob = [[[MPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs] firstObject];

        if (self.currentJob) {
            NSLog(@"PRINT QUEUE - STARTING JOB (%@)", self.currentJob.id);

            NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionaryWithDictionary:[MP sharedInstance].lastOptionsUsed];
            [lastOptionsUsed addEntriesFromDictionary:[MPBTSprocket sharedInstance].analytics];
            [MP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];

            MPPrintItem *item = [self.currentJob.printItems objectForKey:[MPPaper titleFromSize:MPPaperSize2x3]];

            if (item) {
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

        NSLog(@"PRINT QUEUE - ERROR: %@", error);
    }
}

- (void)didFinishSendingPrint:(MPBTSprocket *)sprocket {
    NSLog(@"PRINT QUEUE - JOB SENT TO PRINTER (%@)", self.currentJob.id);
}

- (void)didStartPrinting:(MPBTSprocket *)sprocket {
    NSLog(@"PRINT QUEUE - JOB STARTED PRINTING (%@)", self.currentJob.id);

    [[MPPrintLaterQueue sharedInstance] deletePrintLaterJob:self.currentJob];
    self.currentJob = nil;
}

@end
