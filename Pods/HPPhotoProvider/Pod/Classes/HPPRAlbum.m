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

#import "HPPRAlbum.h"
#import "NSBundle+HPPRLocalizable.h"

@implementation HPPRAlbum

- (id)initWithAttributes:(NSDictionary *)attributes
{
    return nil;
}

- (void)setAttributes:(NSDictionary *)attributes;
{
}

+ (NSError *)albumDeletedError
{
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : HPPRLocalizedString(@"The album was deleted", @"Indicates that a user's photo album was deleted"),
                                       NSLocalizedFailureReasonErrorKey : HPPRLocalizedString(@"Album deleted", @"Indicates that a user's photo album was deleted") };
    
    return [[NSError alloc] initWithDomain:HP_PHOTO_PROVIDER_DOMAIN code:ALBUM_DOES_NOT_EXISTS userInfo:errorDictionary];
}

@end
