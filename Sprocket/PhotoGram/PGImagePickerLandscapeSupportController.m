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

#import "PGImagePickerLandscapeSupportController.h"
#import "UIViewController+Trackable.h"

@implementation PGImagePickerLandscapeSupportController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.trackableScreenName = @"Camera Roll Screen";
}

// UIImagePickerController only supports Portrait mode.
// We have to force the landscape one.
- (NSUInteger)supportedInterfaceOrientations
{
    if (IS_IPHONE) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

@end
