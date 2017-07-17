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

#ifndef Pods_HPPRError_h
#define Pods_HPPRError_h

#define HPPR_ERROR_DOMAIN @"com.hp.hp_photo_provider"

// error codes
typedef enum {
    
    HPPR_ERROR_NO_ERROR = 0,
    HPPR_ERROR_NO_INTERNET_CONNECTION,
    HPPR_ERROR_LOGIN_PROBLEM

} HPPRErrorCode;

// description text
#define HPPR_ERROR_NO_INTERNET_CONNECTION_DESCRIPTION  HPPRLocalizedString(@"Connection to internet was not detected", @"Description to show the user when there is a problem with the internet connection during the login of Instagram, Facebook or Google")
#define HPPR_ERROR_LOGIN_PROBLEM_DESCRIPTION HPPRLocalizedString(@"Unknown login problem", @"Description to show that an unknown problem occurred during the login of Instagram, Facebook or Google")

#endif
