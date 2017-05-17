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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PGPrintQueueManagerDelegate;

@interface PGPrintQueueManager : NSObject

@property (weak, nonatomic) id<PGPrintQueueManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)showPrintQueueStatusFromViewController:(UIViewController *)viewController;
- (void)incrementPrintCounter;

@end


@protocol PGPrintQueueManagerDelegate <NSObject>

@optional;

- (void)pgPrintQueueManagerDidClearQueue:(PGPrintQueueManager *)printQueueManager;

@end
