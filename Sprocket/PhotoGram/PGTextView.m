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

#import "PGTextView.h"

@implementation PGTextView

- (void)drawRect:(CGRect)rect {
    // Work around Bugfix iOS http://stackoverflow.com/questions/18696706/large-text-being-cut-off-in-uitextview-that-is-inside-uiscrollview
    self.scrollEnabled = !self.scrollEnabled;
    self.scrollEnabled = !self.scrollEnabled;
}

@end
