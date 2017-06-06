//
//  PGMetarSource.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/4/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarSource.h"

@implementation PGMetarSource

- (instancetype)initWithDictionary: (NSDictionary *) dict
{
    self = [super init];
    if (self) {
        NSString *from = [dict objectForKey:@"from"];
        if (from != nil) {
            if ([from isEqualToString:@"LOCAL"]) {
                self.from = PGMetarSourceFromLocal;
            } else if ([from isEqualToString:@"SOCIAL"]) {
                self.from = PGMetarSourceFromSocial;
            } else if ([from isEqualToString:@"SHARED"]) {
                self.from = PGMetarSourceFromShared;
            } else if ([from isEqualToString:@"METAR"]) {
                self.from = PGMetarSourceFromMetar;
            } else if ([from isEqualToString:@"OTHER"]) {
                self.from = PGMetarSourceFromOther;
            }
        }
        
        NSString *origin = [dict objectForKey:@"origin"];
        if (origin != nil) {
            if ([origin isEqualToString:@"STORAGE"]) {
                self.origin = PGMetarSourceOriginStorage;
            } else if ([origin isEqualToString:@"OPEN_IN"]) {
                self.origin = PGMetarSourceOriginOpenIn;
            } else if ([origin isEqualToString:@"DOWNLOADED"]) {
                self.origin = PGMetarSourceOriginDownloaded;
            }
        }
        
        self.uri = [dict objectForKey:@"uri"];
        self.album = [dict objectForKey:@"album"];
        
        if ([dict objectForKey:@"social"]) {
            self.social = [[PGMetarSocial alloc] initWithDictionary:[dict objectForKey:@"social"]];
        }
        
        self.identifier = [dict objectForKey:@"id"];
        self.owner = [dict objectForKey:@"owner"];
        
        if ([dict objectForKey:@"livePhoto"]) {
            self.livePhoto = [dict objectForKey:@"livePhoto"];
        } else {
            self.livePhoto = [NSNumber numberWithBool:NO];
        }
    }
    
    return self;
}

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    switch (self.from) {
        case PGMetarSourceFromLocal:
            [dict setObject:@"LOCAL" forKey:@"from"];
            break;
        case PGMetarSourceFromSocial:
            [dict setObject:@"SOCIAL" forKey:@"from"];
            break;
        case PGMetarSourceFromShared:
            [dict setObject:@"SHARED" forKey:@"from"];
            break;
        case PGMetarSourceFromMetar:
            [dict setObject:@"METAR" forKey:@"from"];
            break;
        case PGMetarSourceFromOther:
            [dict setObject:@"OTHER" forKey:@"from"];
            break;
        default:
            break;
    }
    
    switch (self.origin) {
        case PGMetarSourceOriginDownloaded:
            [dict setObject:@"DOWNLOADED" forKey:@"origin"];
            break;
        case PGMetarSourceOriginOpenIn:
            [dict setObject:@"OPEN_IN" forKey:@"origin"];
            break;
        case PGMetarSourceOriginStorage:
            [dict setObject:@"STORAGE" forKey:@"origin"];
            break;
        default:
            break;
    }
    
    if (self.uri)
        [dict setObject:self.uri forKey:@"uri"];
    
    if (self.album)
        [dict setObject:self.album forKey:@"album"];
   
    if (self.social)
        [dict setObject:[self.social getDict] forKey:@"social"];
    
    if (self.identifier)
        [dict setObject:self.identifier forKey:@"id"];
    
    if (self.owner)
        [dict setObject:self.owner forKey:@"owner"];
    
    if (self.livePhoto)
        [dict setObject:self.livePhoto forKey:@"livePhoto"];
    
    return dict;
}
@end
