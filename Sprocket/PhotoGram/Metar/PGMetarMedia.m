//
//  PGMetarMedia.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/4/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarMedia.h"

@implementation PGMetarMedia

- (instancetype)initWithDictionary: (NSDictionary *) dict
{
    self = [super init];
    if (self) {
        self.mime = [dict objectForKey:@"mime"];
    }
    return self;
}

- (NSDictionary *) getDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.mime)
        [dict setObject:self.mime forKey:@"mime"];
    
    if ([self getMediaType])
        [dict setObject:[self getMediaType] forKey:@"mediaType"];
    
    return dict;
}

- (NSString *) getMediaType {
    if (self.mediaType == PGMetarMediaTypeVideo) {
        return @"video";
    } else if (self.mediaType == PGMetarMediaTypeImage) {
        return @"image";
    } else {
        return nil;
    }
}

+(instancetype)metaFromHPPRMedia: (HPPRMedia *) media {
    PGMetarMedia *meta = [[self alloc] init];
    
    switch (media.mediaType) {
        case kHPRMediaTypeImage:
            meta.mediaType = PGMetarMediaTypeImage;
            break;
        case kHPRMediaTypeVideo:
            meta.mediaType = PGMetarMediaTypeVideo;
            break;
        default:
            break;
    }
    
    return meta;
}

@end
