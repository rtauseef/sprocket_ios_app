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
#import "HPPRInstagramError.h"
#import "HPPR.h"
#import "NSBundle+HPPRLocalizable.h"

@implementation HPPRInstagramError

+ (HPPRInstagramErrorType)errorType:(NSError *)error
{

    HPPRInstagramErrorType instagramError = INSTAGRAM_NO_ERROR;
    
    if (error != nil) {
        
        switch (error.code) {
            case THE_OPERATION_COULD_NOT_BE_COMPLETED_ERROR_CODE:
                instagramError = INSTAGRAM_OP_COULD_NOT_COMPLETE;
                break;
                
            case NO_INTERNET_CONNECTION_ERROR_CODE:
                instagramError = INSTAGRAM_NO_INTERNET_CONNECTION;
                break;
                
            case REQUEST_FAIL_ERROR_CODE:
                {
                    // Note: error.description is not always an NSString, in iPhone 4 iOS 7 for example is a NSCFString (NSCFString does not implement the method containsString), so range is used instead for comparing if the string is contained in the error description.
                    NSRange rangeAccessTokenIsInvalid = [error.description rangeOfString:THE_ACCESS_TOKEN_IS_INVALID];
                    NSRange rangeUserAccountIsPrivate = [error.description rangeOfString:USER_ACCOUNT_IS_PRIVATE];
                    
                    if (rangeAccessTokenIsInvalid.length > 0) {
                        instagramError = INSTAGRAM_TOKEN_IS_INVALID;
                    } else if (rangeUserAccountIsPrivate.length > 0) {
                        instagramError = INSTAGRAM_USER_ACCOUNT_IS_PRIVATE;
                    } else {
                        [HPPRInstagramError printUnrecognizedData:error];
                        instagramError = INSTAGRAM_UNRECOGNIZED_ERROR;
                    }
                }
                break;
                
            default:
                [HPPRInstagramError printUnrecognizedData:error];
                instagramError = INSTAGRAM_UNRECOGNIZED_ERROR;
                break;
        }
    }

    return instagramError;
}

+ (void)printUnrecognizedData:(NSError *)error {
    NSLog(@"Unrecognized Instagram error- domain: %@ code: %ld description: %@", error.domain, (long)error.code, error.description);
}

@end
