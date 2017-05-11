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

#import "PGView.h"
#import <AirshipKit.h>

@interface PGInAppMessageView : PGView

@property (weak, nonatomic) IBOutlet UIButton *primaryButton;
@property (weak, nonatomic) IBOutlet UIButton *secondaryButton;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;


- (instancetype)initWithMessage:(UAInAppMessage *)message;

- (void)setupConstraints;

- (void)show;
- (void)hide;

@end
