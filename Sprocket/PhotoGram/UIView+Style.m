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

#import "UIView+Style.h"

@implementation UIView (Style)

- (void)changeFont:(UIFont *)font
{
    if ([self respondsToSelector:@selector(setFont:)]) {
        [self performSelector:@selector(setFont:) withObject:font];
	}
	
    for (UIView *view in self.subviews) {
        [view changeFont:font];
	}
}

- (CAShapeLayer *)dashedBorder
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    CGSize frameSize = self.frame.size;
    
    CGRect shapeRect = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake(frameSize.width/2, frameSize.height/2)];
    
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    [shapeLayer setLineWidth:1.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:
                                    [NSNumber numberWithInt:3],
                                    [NSNumber numberWithInt:5],
                                    nil]];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:0.0f];
    [shapeLayer setPath:path.CGPath];
    
    return shapeLayer;
}

@end
