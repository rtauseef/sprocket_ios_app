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

#import "UIColor+HexString.h"


@implementation UIColor(HexString)

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue  = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start: 0 length:1];
            red   = [self colorComponentFrom:colorString start: 1 length:1];
            green = [self colorComponentFrom:colorString start: 2 length:1];
            blue  = [self colorComponentFrom:colorString start: 3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start: 0 length:2];
            green = [self colorComponentFrom:colorString start: 2 length:2];
            blue  = [self colorComponentFrom:colorString start: 4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red   = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue  = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            PGLogError(@"Invalid color value: Color value %@ is invalid. It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString);
            alpha = 1.0f;
            red   = 0.0f;
            green = 0.0f;
            blue  = 0.0f;
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length
{
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

+ (NSString *)hexStringWithColor:(UIColor *)color
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    red *= 255;
    green *= 255;
    blue *= 255;
    return [NSString stringWithFormat:@"#%2X%2X%2X", (int)red, (int)green, (int)blue];
}

@end
