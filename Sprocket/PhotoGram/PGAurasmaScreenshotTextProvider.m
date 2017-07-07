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

#import "PGAurasmaScreenshotTextProvider.h"

@implementation PGAurasmaScreenshotTextProvider

+ (PGAurasmaScreenshotTextProvider *)textProvider {
    return [PGAurasmaScreenshotTextProvider new];
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType {
    
    NSString *text;
    
    if (activityType == UIActivityTypePostToTwitter) {
        NSString *appName = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey];
        appName = [appName stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        text = [NSString stringWithFormat:NSLocalizedString(@"Check out what I saw in #%@! via @HP #sprocket", @""),
                appName];
    }
    else {
        text = @"";
    }
    
    return text;
}

@end
