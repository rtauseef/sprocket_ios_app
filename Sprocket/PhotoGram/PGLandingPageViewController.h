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
#import <TTTAttributedLabel.h>
#import <HPPRLoginProvider.h>
#import <HPPRError.h>

extern const NSInteger PGLandingPageViewControllerCollectionViewBottomInset;

@interface PGLandingPageViewController : UIViewController <TTTAttributedLabelDelegate>

- (void)setLinkForLabel:(TTTAttributedLabel *)label range:(NSRange)range;

- (void)showLogin;
- (void)showNoConnectionAvailableAlert;
- (void)showAlbums;

@end
