//
//  PGAurasmaScreenshotTextProvider.m
//  Sprocket
//
//  Created by Alex Walter on 12/06/2017.
//  Copyright © 2017 HP. All rights reserved.
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
