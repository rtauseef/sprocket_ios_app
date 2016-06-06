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

#import "PGSVGText.h"
#import "UIColor+HexString.h"

@implementation PGSVGText

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.name = name;
        
        self.editable = [name isEqualToString:@"description"];
        
        // TODO. Put correct text
        self.text = name;
        
        self.fields = [NSMutableDictionary dictionaryWithObjects:@[@"", @"", @"", @"", @"", @""] forKeys:@[@"Font", @"Size", @"Color", @"Alignment", @"Format", @"InclinationAngleInDegrees"]];
    }
    return self;
}


- (NSString *)fontValue
{
    return [self.fields objectForKey:@"Font"];
}

- (NSString *)sizeValue
{
    return [self.fields objectForKey:@"Size"];
}

- (NSString *)colorValue
{
    return [self.fields objectForKey:@"Color"];
}

- (NSString *)alignmentValue
{
    return [self.fields objectForKey:@"Alignment"];
}

- (NSString *)dateFormatValue
{
    return [self.fields objectForKey:@"Format"];
}

- (NSString *)inclinationAngleInDegreesValue
{
    return [self.fields objectForKey:@"InclinationAngleInDegrees"];
}

- (UIFont *)font
{
    NSString *fontName = self.fontValue;
    CGFloat size = [self.sizeValue floatValue];
    
    UIFont *font = [UIFont fontWithName:fontName size:size];
    
    return font;
}

- (UIColor *)color
{
    return [UIColor colorWithHexString:self.colorValue];
}

- (NSTextAlignment)textAlignment
{
    if ([self.alignmentValue isEqualToString:@"left"]) {
        return NSTextAlignmentLeft;
    } else if ([self.alignmentValue isEqualToString:@"right"]) {
        return NSTextAlignmentRight;
    } else {
        return NSTextAlignmentCenter;
    }
}

- (NSDateFormatter *)dateFormatter
{
    NSDateFormatter *dateFormatter = nil;
    if (self.dateFormatValue != nil) {
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:self.dateFormatValue options:0 locale:[NSLocale currentLocale]];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formatString];
    }
    
    return dateFormatter;
}

- (CGFloat)inclinationAngleInDegrees
{
    CGFloat result = 0.0f;
    
    if (self.inclinationAngleInDegreesValue != nil) {
        result = [self.inclinationAngleInDegreesValue floatValue];
    }
    
    return result;
}

- (id)initWithText:(NSString *)text font:(UIFont *)font frame:(CGRect)frame color:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.text = text;
        self.font = font;
        self.frame = frame;
        self.color = color;
    }
    return self;
}

- (NSString *)description
{
    NSString *descriptionString = [NSString stringWithFormat:@"Name:%@ \n%@ \nPosition: %f, %f \nSize: %f, %f\n", self.name, self.fields, self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height];
    
    return descriptionString;
}

@end
