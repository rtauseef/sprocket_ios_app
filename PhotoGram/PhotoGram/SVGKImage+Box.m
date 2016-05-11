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

#import <SVGRectElement.h>
#import "SVGKImage+Box.h"

@implementation SVGKImage (Box)

- (CGRect)picBox
{
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"picBox"];
    
    return [self rectForElement:rectElement];
}

- (CGRect)locationIconBox
{
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"locationIconBox"];
    
    return [self rectForElement:rectElement];
}

- (CGRect)dateIconBox
{
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"dateIconBox"];
    
    return [self rectForElement:rectElement];
}

- (CGRect)isoIconBox
{
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"ISOIconBox"];
    
    return [self rectForElement:rectElement];
}

- (CGRect)shutterSpeedIconBox
{
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"shutterIconBox"];
    
    return [self rectForElement:rectElement];
}

- (CGRect)calendarIconBox
{
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"calendarIconBox"];
    
    return [self rectForElement:rectElement];
}

- (CGRect)likesIconBox
{
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"likesIconBox"];
    
    return [self rectForElement:rectElement];
    
}

- (CGRect)facebookLikesIconBox
{
    CGRect iconRect;
    
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"facebookLikesIconBox"];
    if( rectElement ) {
        [self rectForElement:rectElement];
    }
    else {
        iconRect = [self likesIconBox];
    }
   
    return iconRect;
}

- (CGRect)flickrLikesIconBox
{
    CGRect iconRect;
    
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"flickrLikesIconBox"];
    if( rectElement ) {
        [self rectForElement:rectElement];
    }
    else {
        iconRect = [self likesIconBox];
    }
    
    return iconRect;

}

- (CGRect)instagramLikesIconBox
{
    CGRect iconRect;
    
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"instagramLikesIconBox"];
    if( rectElement ) {
        [self rectForElement:rectElement];
    }
    else {
        iconRect = [self likesIconBox];
    }
    
    return iconRect;
}

- (CGRect)commentsIconBox
{
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"commentsIconBox"];
    
    return [self rectForElement:rectElement];
}

- (CGRect)userImageBox
{
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:@"userimageBox"];
    
    return [self rectForElement:rectElement];
}

- (CGRect)textBoxForField:(NSString *)fieldName
{
    NSString *fieldNameComplete = [NSString stringWithFormat:@"%@Box", fieldName];
    
    SVGRectElement *rectElement = (SVGRectElement *)[self.DOMTree getElementById:fieldNameComplete];
    
    return [self rectForElement:rectElement];
}

- (CGRect)rectForElement:(SVGRectElement *)rectElement
{
    NSString *rectString = [NSString stringWithFormat:@"{{%@,%@},{%@,%@}}",
                                   [rectElement getAttribute:@"x"],
                                   [rectElement getAttribute:@"y"],
                                   [rectElement getAttribute:@"width"],
                                   [rectElement getAttribute:@"height"]];
    CGRect frame = CGRectFromString(rectString);
    
    return frame;
}

@end
