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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HPPRInstagramError : NSObject

    typedef enum HPPRInstagramErrorType {
        INSTAGRAM_NO_ERROR,
        INSTAGRAM_OP_COULD_NOT_COMPLETE,
        INSTAGRAM_NO_INTERNET_CONNECTION,
        INSTAGRAM_TOKEN_IS_INVALID,
        INSTAGRAM_USER_ACCOUNT_IS_PRIVATE,
        INSTAGRAM_TIME_OUT_ERROR,
        INSTAGRAM_UNRECOGNIZED_ERROR
    } HPPRInstagramErrorType;

    @property (assign) HPPRInstagramErrorType errorType;

+ (HPPRInstagramErrorType)errorType:(NSError *)error;

@end
