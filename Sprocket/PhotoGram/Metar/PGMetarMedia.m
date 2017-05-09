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
    
    if (self.size)
        [dict setObject:self.size forKey:@"size"];
    
    if ([self getOrientation])
        [dict setObject:[self getOrientation] forKey:@"orientation"];
    
    if (self.pixels.height != 0 && self.pixels.width != 0) {
        NSDictionary *pixelsDict = @{@"width" : [NSNumber numberWithFloat:self.pixels.width],
                                     @"height" : [NSNumber numberWithFloat:self.pixels.height]};
    
        [dict setObject:pixelsDict forKey:@"pixels"];
    }
    
    if (self.inches.height != 0 && self.inches.width != 0) {
        NSDictionary *inchesDict = @{@"width" : [NSNumber numberWithFloat:self.inches.width],
                                     @"height" : [NSNumber numberWithFloat:self.inches.height]};
        
        [dict setObject:inchesDict forKey:@"inches"];
    }
    
    if (self.created) {
        time_t unixTime = (time_t) [self.created timeIntervalSince1970];
        [dict setObject:[NSNumber numberWithDouble:unixTime] forKey:@"created"];
    }
    
    if (self.submitted) {
        time_t unixTime = (time_t) [self.submitted timeIntervalSince1970];
        [dict setObject:[NSNumber numberWithDouble:unixTime] forKey:@"submitted"];
    }
    
    if (self.lastQueried) {
        time_t unixTime = (time_t) [self.lastQueried timeIntervalSince1970];
        [dict setObject:[NSNumber numberWithDouble:unixTime] forKey:@"lastQueried"];
    }
    
    if (self.source) {
        [dict setObject:[self.source getDict] forKey:@"source"];
    }
    
    if (self.tags) {
        // build array
    }
    
    if (self.video) {
        //
    }
    
    if (self.image) {
        //
    }
    
    if (self.artifacts) {
        // build array
    }
    
    if (self.location) {
        [dict setObject:[self.location getDict] forKey:@"location"];
    }
    
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

- (NSString *) getOrientation {
    if (self.orientation == PGMetarMediaOrientationPortrait) {
        return @"portrait";
    } else if (self.mediaType == PGMetarMediaOrientationLandscape) {
        return @"landscape";
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
    
    meta.created = [media createdTime];
    
    if (media.image != nil) {
        meta.pixels = media.image.size;
        
        //WARNING: this DPI is an approximate
        float scale = 1;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            scale = [[UIScreen mainScreen] scale];
        }
        float dpi = 160 * scale;
        
        float width  = meta.pixels.width / dpi;
        float height = meta.pixels.height / dpi;
        
        meta.inches = CGSizeMake(width, height);
    }
    
    if (media.location) {
        PGMetarLocation *location = [[PGMetarLocation alloc] init];
        location.geo = media.location.coordinate;
        location.altitude = media.location.altitude;
        location.name = media.locationName;
        
        meta.location = location;
    }
    
    if (media.socialMediaImageUrl) {
        PGMetarSource *source = [[PGMetarSource alloc] init];
        source.uri = media.socialMediaImageUrl;
        source.owner = media.userName;

        meta.source = source;
    }
    
    return meta;
}

@end
