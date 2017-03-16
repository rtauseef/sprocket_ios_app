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

typedef NS_ENUM(NSUInteger, MPBTPrinterManagerStatus) {
    MPBTPrinterManagerStatusEmptyQueue,
    MPBTPrinterManagerStatusIdle,
    MPBTPrinterManagerStatusWaitingForPrinter,
    MPBTPrinterManagerStatusSendingPrintJob,
    MPBTPrinterManagerStatusPrinting
};

@interface MPBTPrintManager : NSObject

@property (nonatomic, assign, readonly) NSInteger queueSize;
@property (nonatomic, assign, readonly) MPBTPrinterManagerStatus status;

+ (instancetype)sharedInstance;

- (void)addPrintItemToQueue:(MPPrintItem *)printItem;

- (void)resumePrintQueue;

- (void)cancelPrintQueue;

@end
