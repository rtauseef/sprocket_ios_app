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
#import "HPPRLoginViewController.h"

@protocol HPPRFlickrLoginViewControllerDelegate;

@interface HPPRFlickrLoginViewController : HPPRLoginViewController

@property (nonatomic, weak) id<HPPRFlickrLoginViewControllerDelegate> delegate;

@end


@protocol HPPRFlickrLoginViewControllerDelegate <NSObject>

- (void)flickrLoginViewControllerDidFail:(HPPRFlickrLoginViewController *)flickrLoginViewController;
- (void)flickrLoginViewControllerDidCancel:(HPPRFlickrLoginViewController *)flickrLoginViewController;

@end
