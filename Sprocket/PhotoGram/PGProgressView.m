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

#import "PGProgressView.h"


@interface PGProgressView()

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *sublabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sublabelHeight;

@end

@implementation PGProgressView

- (void)setText:(NSString *)text {
    self.label.text = text;
}

- (void)setSubText:(NSString *)text {
    if (text) {
        self.sublabel.text = text;
    } else {
        self.sublabelHeight.constant = 0;
    }
}

- (void)setProgress:(CGFloat)progress {
    self.progressBar.progress = progress;
}

@end
