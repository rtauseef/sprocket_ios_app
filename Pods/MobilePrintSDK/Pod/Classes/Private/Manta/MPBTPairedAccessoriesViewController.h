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

#import <UIKit/UIKit.h>
#import "MPBTSprocket.h"
#import "MPBTImageProcessor.h"

@protocol MPBTPairedAccessoriesViewControllerDelegate;

@interface MPBTPairedAccessoriesViewController : UIViewController

@property (weak, nonatomic) id<MPBTPairedAccessoriesViewControllerDelegate> delegate;
@property (strong, nonatomic) void (^completionBlock)(BOOL userDidSelect);

+ (instancetype)pairedAccessoriesViewControllerForPrint;
+ (instancetype)pairedAccessoriesViewControllerForDeviceInfo;

+ (void)presentAnimatedForDeviceInfo:(BOOL)animated usingController:(UIViewController *)hostController andCompletion:(void(^)(void))completion;
+ (void)presentAnimatedForPrint:(BOOL)animated image:(UIImage *)image processor:(MPBTImageProcessor *) processor usingController:(UIViewController *)hostController andPrintCompletion:(void(^)(void))completion;

- (void)presentNoPrinterConnectedAlert:(UIViewController *)hostController showConnectSprocket:(BOOL)showConnectSprockets;

+ (NSString *)lastPrinterUsed;
+ (void)setLastPrinterUsed:(NSString *)lastPrinterUsed;

@end

@protocol MPBTPairedAccessoriesViewControllerDelegate <NSObject>

- (void)pairedAccessoriesViewController:(MPBTPairedAccessoriesViewController *)controller didSelectSprocket:(MPBTSprocket *)sprocket;

@end;
