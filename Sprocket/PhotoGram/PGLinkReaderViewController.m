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

#import "PGLinkReaderViewController.h"
#import "PGLinkCredentialsManager.h"
#import "LRManagerPrivate.h"
#import "LRLinkServicesPrivate.h"

@interface EasyReadingViewController()
- (void)startScanning;
- (void)dismissThisController;
@end

@interface PGLinkReaderViewController ()
@end

@implementation PGLinkReaderViewController

-(instancetype)init {
    if (self = [super initWithClientID:[PGLinkCredentialsManager clientId] secret:[PGLinkCredentialsManager clientSecret] delegate:nil success:nil failure:nil]) {
    }
    return self;
}

-(void)doAuthenticationSuccess:(void (^)(void))success failure:(void (^)(NSError * error))failure {
    [LRLinkServices setCurrentLppStack:LppStackProduction];
    [[LRManager sharedManager] authorizePartnerAppWithClientID:[PGLinkCredentialsManager clientId] secret:[PGLinkCredentialsManager clientSecret]];
}

-(void)reportError:(NSError *)error {
    if ([error.domain isEqualToString:LR_PAYOFF_RESOLVER_ERROR_DOMAIN]) {
        switch (error.code) {
            case LRPayoffResolverErrorCode_RequestCancelled:
                [self startScanning];
                break;
            case LRPayoffResolverErrorCode_ConnectionError:
            case LRPayoffResolverErrorCode_NetworkRequestTimedOut:
            case LRPayoffResolverErrorCode_NetworkConnectionLost:
                [self alertWithTitle:@"Connection Error" message:@"It looks like you aren’t connected to the Internet. Scanning the image requires an internet connection to retrieve the content."];
                break;
            default:
                [self alertWithTitle:@"Error while retrieving content" message:@"The content to be presented could not be retrieved."];
                break;
        }
    }else if ([error.domain isEqualToString:LR_PAYOFF_RESOLVER_ERROR_DOMAIN]) {
        switch (error.code) {
            case LRPayoffErrorCode_MissingOrUnknownPayoffType:
                [self alertWithTitle:@"Content Error" message:@"We do not support scanning that content."];
                break; 
            case LRPayoffErrorCode_InvalidPayoffData:
            case LRPayoffErrorCode_PayoffNotPresentInData:
            case LRPayoffErrorCode_InvalidPayoffFormat:
                [self alertWithTitle:@"Content Error" message:@"An error ocurred and the content could not be presented."];
                break;
            default:
                [self alertWithTitle:@"Content Error" message:@"An error ocurred and the content could not be presented."];
                break;
        }
    }else if ([error.domain isEqualToString:LinkReaderCameraErrorDomain]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Scanner Error" message:@"An error has ocurred when trying to present the scanner" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:^{
            [self dismissThisController];
        }];
    }
}

- (void)alertWithTitle:(NSString*)title message:(NSString *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [self startScanning];
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
