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

#import "PGInboxMessageViewController.h"
#import "UIColor+Style.h"

@interface PGWebViewerViewController () <UIWebViewDelegate>

@end

@implementation PGInboxMessageViewController

- (void)viewDidLoad {
    [self setUrl:[self.message.messageBodyURL absoluteString]];
    self.urlRequestHeaders = @{@"Authorization":[UAUtils userAuthHeaderString]};

    self.title = self.message.title;
    self.view.backgroundColor = [UIColor HPDarkBackgroundColor];

    [super viewDidLoad];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];

    [self.message markMessageReadWithCompletionHandler:nil];
}

@end
