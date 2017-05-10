//
//  PGMetarSocial.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/9/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarSocial.h"

@implementation PGMetarSocial

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
