//
//  PGAurasmaRecordingViewController.h
//  Sprocket
//
//  Created by Alex Walter on 12/06/2017.
//  Copyright © 2017 HP. All rights reserved.
//
#import <UIKit/UIKit.h>

@class PGAurasmaRecordingViewController;

@protocol PGAurasmaRecordingViewControllerDelegate <NSObject>

- (void)closeRecordingViewController:(PGAurasmaRecordingViewController *)controller;

@end

@interface PGAurasmaRecordingViewController : UIViewController

@property (nonatomic, weak, readwrite) id<PGAurasmaRecordingViewControllerDelegate> recordingDelegate;
@property (nonatomic, strong, readwrite) NSURL *fileUrl;

@end
