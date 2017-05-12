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
#import <LinkReaderKit/LRManager.h>

@interface LRManager(PartnerPrivate)

/**
 Authenticates a partner app. The application's bundle id be included in the list of registered partner app ids.
 
 @param clientID    The client identifier
 @param secret      The client secret
 
 @since 1.1.2
 */
- (void)authorizePartnerAppWithClientID:(NSString *)clientID secret:(NSString *)secret;

@end
