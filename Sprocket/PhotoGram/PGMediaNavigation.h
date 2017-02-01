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

#import <UIKit/UIKit.h>
#import "PGView.h"
#import "PGSocialSourcesManager.h"

@protocol PGMediaNavigationDelegate;

@interface PGMediaNavigation : PGView

@property (strong, nonatomic) PGSocialSource *socialSource;
@property (weak, nonatomic) id<PGMediaNavigationDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)hideCameraButton;
- (void)showCameraButton;
- (void)hideGradientBar;
- (void)showGradientBar;

- (void)showAlbumsDropDownButtonUp:(BOOL)animated;
- (void)showAlbumsDropDownButtonDown:(BOOL)animated;
- (void)hideAlbumsDropDownButton;

@end

@protocol PGMediaNavigationDelegate <NSObject>

- (void)mediaNavigationDidPressMenuButton:(PGMediaNavigation *)mediaNav;
- (void)mediaNavigationDidPressFolderButton:(PGMediaNavigation *)mediaNav;
- (void)mediaNavigationDidPressCameraButton:(PGMediaNavigation *)mediaNav;

@end
