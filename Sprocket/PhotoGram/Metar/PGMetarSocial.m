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

#import "PGMetarSocial.h"

@implementation PGMetarSocial


- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    if (self) {
        if ([dict objectForKey:@"provider"] != nil) {
            self.provider = [self getProviderFromString:[dict objectForKey:@"provider"]];
        }
        
        if ([dict objectForKey:@"type"] != nil) {
            self.type = [self getTypeFromString:[dict objectForKey:@"type"]];
        }
        
        self.uri = [dict objectForKey:@"uri"];
        self.assetId = [dict objectForKey:@"assetId"];
        self.profileUri = [dict objectForKey:@"profileUri"];
        self.profileId = [dict objectForKey:@"profileId"];
        
        if ([dict objectForKey:@"activity"] != nil) {
            PGMetarSocialActivity *socialActivity = [[PGMetarSocialActivity alloc] initWithDictionary:[dict objectForKey:@"activity"]];
            self.activity = socialActivity;
        }
    }
    return self;
}

- (PGMetarSocialType) getTypeFromString: (NSString *) type {
    if ([type rangeOfString:@"post" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarSocialTypePost;
    } else if ([type rangeOfString:@"picture" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarSocialTypePicture;
    } else if ([type rangeOfString:@"video" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarSocialTypeVideo;
    }
    
    return PGMetarSocialTypeUnknown;
}

- (PGMetarSocialProvider) getProviderFromString: (NSString *) provider {
    if ([provider rangeOfString:@"facebook" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarSocialProviderFacebook;
    } else if ([provider rangeOfString:@"instagram" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarSocialProviderInstagram;
    } else if ([provider rangeOfString:@"google" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarSocialProviderGoogle;
    } else if ([provider rangeOfString:@"flickr" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return PGMetarSocialProviderFlickr;
    }
    
    return PGMetarSocialProviderUnknown;
}

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    switch (self.provider) {
        case PGMetarSocialProviderFacebook:
            [dict setObject:@"Facebook" forKey:@"provider"];
            break;
        case PGMetarSocialProviderInstagram:
            [dict setObject:@"Instagram" forKey:@"provider"];
            break;
        case PGMetarSocialProviderGoogle:
            [dict setObject:@"Google" forKey:@"provider"];
            break;
        case PGMetarSocialProviderFlickr:
            [dict setObject:@"Flickr" forKey:@"provider"];
            break;
        default:
            break;
    }
    
    switch (self.type) {
        case PGMetarSocialTypePost:
            [dict setObject:@"Post" forKey:@"type"];
            break;
        case PGMetarSocialTypeVideo:
            [dict setObject:@"Video" forKey:@"type"];
            break;
        case PGMetarSocialTypePicture:
            [dict setObject:@"Picture" forKey:@"type"];
            break;
        default:
            break;
    }
    
    if (self.uri)
        [dict setObject:self.uri forKey:@"uri"];
    
    if (self.assetId)
        [dict setObject:self.assetId forKey:@"assetId"];
    
    if (self.profileUri)
        [dict setObject:self.profileUri forKey:@"profileUri"];
    
    if (self.profileId)
        [dict setObject:self.profileId forKey:@"profileId"];
    
    if (self.activity)
        [dict setObject:[self.activity getDict] forKey:@"activity"];
        
    return dict;
}

@end
