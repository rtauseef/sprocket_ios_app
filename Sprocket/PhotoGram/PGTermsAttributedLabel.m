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

#import <HPPR.h>

#import "PGTermsAttributedLabel.h"
#import "UIColor+Style.h"

@implementation PGTermsAttributedLabel

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.textColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRPrimaryLabelColor];
        self.minimumLineHeight = 19.9f;
        self.numberOfLines = 2;
        [self setLinkForLabel:self range:[self.text rangeOfString:NSLocalizedString(@"Terms of Service", @"Phrase to make link for terms of service of the landing page") options:NSCaseInsensitiveSearch]];
    }
    return self;
}

- (void)setLinkForLabel:(TTTAttributedLabel *)label range:(NSRange)range
{
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    [linkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [linkAttributes setValue:(__bridge id)[[UIColor HPLinkColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    label.linkAttributes = linkAttributes;
    label.activeLinkAttributes = linkAttributes;
    
    label.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    label.text = label.text;
    
    [label addLinkToURL:[NSURL URLWithString:@"#"] withRange:range];
}

@end
