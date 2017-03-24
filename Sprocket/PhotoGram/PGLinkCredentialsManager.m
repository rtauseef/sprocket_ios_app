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


#import "PGLinkCredentialsManager.h"
#import <LivePaperSDK/LPSession.h>

static NSString *const LPPClientId = @"sxpjwjjoi3u0sfljtcusez8knpo2q22q"; 
static NSString *const LPPClientSecret = @"dO29dedfySjzFOQ2z2WLYExEh6hIiCF8";

@implementation PGLinkCredentialsManager

+ (NSString*)clientId {
    return LPPClientId;
}

+ (NSString*)clientSecret {
    return LPPClientSecret;
}

+ (LPStack)stack {
    return LPStack_Production;
}

+ (NSString *)stackString {
    switch ([self stack]) {
        case LPStack_Production:
            return @"LPStack_Production";
        case LPStack_Staging:
            return @"LPStack_Staging";
        case LPStack_Development:
            return @"LPStack_Development";
    }
}

@end
