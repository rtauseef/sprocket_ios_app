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

@interface PGSVGText : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSMutableDictionary *fields;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) CGFloat inclinationAngleInDegrees;

@property (nonatomic, strong) NSString *fontValue;
@property (nonatomic, strong) NSString *sizeValue;
@property (nonatomic, strong) NSString *colorValue;
@property (nonatomic, strong) NSString *alignmentValue;
@property (nonatomic, strong) NSString *dateFormatValue;
@property (nonatomic, strong) NSString *inclinationAngleInDegreesValue;

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) BOOL editable;

- (id)initWithText:(NSString *)text font:(UIFont *)font frame:(CGRect)frame color:(UIColor *)color;
- (id)initWithName:(NSString *)name;

@end
