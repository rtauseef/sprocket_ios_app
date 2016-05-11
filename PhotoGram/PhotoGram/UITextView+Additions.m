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

#import "UITextView+Additions.h"

@implementation UITextView (Additions)

- (BOOL)isAllTextVisible
{
    CGRect textRect = [self.attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             context:nil];
    
    return (textRect.size.height <= self.frame.size.height);
}

@end
