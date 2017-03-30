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

#import "MPPrintItem.h"
#import "MPPrintLaterJob.h"

typedef NS_ENUM(NSUInteger, MPBTPrinterManagerStatus) {
    MPBTPrinterManagerStatusEmptyQueue,
    MPBTPrinterManagerStatusResumingPrintQueue,
    MPBTPrinterManagerStatusIdle,
    MPBTPrinterManagerStatusWaitingForPrinter,
    MPBTPrinterManagerStatusSendingPrintJob,
    MPBTPrinterManagerStatusPrinting
};

@protocol MPBTPrintManagerDelegate;

@interface MPBTPrintManager : NSObject

@property (nonatomic, assign, readonly) NSInteger queueId;
@property (nonatomic, assign, readonly) NSInteger originalQueueSize;
@property (nonatomic, readonly) NSString *printerId;
@property (nonatomic, readonly) NSDictionary *printerAnalytics;
@property (nonatomic, assign, readonly) NSInteger queueSize;
@property (nonatomic, assign, readonly) MPBTPrinterManagerStatus status;
@property (nonatomic, weak) id<MPBTPrintManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (BOOL)addPrintItemToQueue:(MPPrintItem *)printItem;

- (void)resumePrintQueue:(BOOL (^)(MPBTPrinterManagerStatus status, NSInteger progress))statusUpdate;
- (void)pausePrintQueue;
- (void)cancelPrintQueue;

@end


@protocol MPBTPrintManagerDelegate <NSObject>

- (void)btPrintManagerDidResumePrintQueue:(MPBTPrintManager *)printManager;
- (void)btPrintManagerDidClearPrintQueue:(MPBTPrintManager *)printManager;
- (void)btPrintManagerDidFinishPrintQueue:(MPBTPrintManager *)printManager;
- (void)btPrintManager:(MPBTPrintManager *)printManager didStartSendingPrintJob:(MPPrintLaterJob *)job;
- (void)btPrintManager:(MPBTPrintManager *)printManager sendingPrintJob:(MPPrintLaterJob *)job progress:(NSInteger)progress;
- (void)btPrintManager:(MPBTPrintManager *)printManager didFinishSendingPrintJob:(MPPrintLaterJob *)job;
- (void)btPrintManager:(MPBTPrintManager *)printManager didStartPrintingJob:(MPPrintLaterJob *)job;
- (void)btPrintManager:(MPBTPrintManager *)printManager didReceiveError:(NSInteger)errorCode forPrintJob:(MPPrintLaterJob *)job;

@end
