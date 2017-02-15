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
        self.numberOfLines = 3;
        self.minimumLineHeight = 19.9f;
        
        // Use this variable in the future, when we receive all files with this translation.
        NSString *termsText = NSLocalizedString(@"By authenticating with %@, you also agree with HP’s <Terms of Service>.", @"Terms of Service String. PS: Don't remove %@ nor < and >");
        
        NSRange tagStart = [self.text rangeOfString:@"<" options:NSCaseInsensitiveSearch];
        NSRange tagEnd = [self.text rangeOfString:@">" options:NSCaseInsensitiveSearch];

        self.text  = [self.text stringByReplacingOccurrencesOfString:@"<" withString:@""];
        self.text  = [self.text stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        [self setLinkForLabel:self range:NSMakeRange(tagStart.location, (tagEnd.location - 1) - tagStart.location)];
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
