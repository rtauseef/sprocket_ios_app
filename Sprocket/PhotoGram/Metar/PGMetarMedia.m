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
        [dict setObject:[self getMediaType] forKey:@"type"];
    
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
        [dict setObject:self.tags forKey:@"tags"];
    }
    
    if (self.video) {
        [dict setObject:[self.video getDict] forKey:@"video"];
    }
    
    if (self.image) {
        [dict setObject:[self.image getDict] forKey:@"image"];
    }
    
    if (self.artifacts) {
        NSMutableArray *artifactArray = [NSMutableArray array];
        
        for (PGMetarArtifact *artifact in self.artifacts) {
            [artifactArray addObject:[artifact getDict]];
        }
             
        [dict setObject:artifactArray forKey:@"artifacts"];
    }
    
    if (self.location) {
        [dict setObject:[self.location getDict] forKey:@"location"];
    }
    
    return dict;
}

- (NSString *) getMediaType {
    if (self.mediaType == PGMetarMediaTypeVideo) {
        return @"VIDEO";
    } else if (self.mediaType == PGMetarMediaTypeImage) {
        return @"IMAGE";
    } else {
        return nil;
    }
}

- (NSString *) getOrientation {
    if (self.orientation == PGMetarMediaOrientationPortrait) {
        return @"PORTRAIT";
    } else if (self.orientation == PGMetarMediaOrientationLandscape) {
        return @"LANDSCAPE";
    } else {
        return nil;
    }
}

- (PGMetarImage *) getImageAttributesForMedia: (HPPRMedia *) media {
    PGMetarImage *image = [[PGMetarImage alloc] init];
    
    image.iso = media.isoSpeed;
    image.exposure = media.exposureTime;
    image.aperture = media.aperture;
    image.usedFlash = media.flash;
    image.make = media.cameraMake;
    image.model = media.cameraModel;
    media.focalLength = media.focalLength;
        
    return image;
}

- (PGMetarVideo *) getVideoAttributesForMedia: (HPPRMedia *) media {
    PGMetarVideo *video = [[PGMetarVideo alloc] init];
    
    video.length = media.videoDuration;
    
    return video;
}

+(instancetype)metaFromHPPRMedia: (HPPRMedia *) media {
    PGMetarMedia *meta = [[self alloc] init];
    
    switch (media.mediaType) {
        case kHPRMediaTypeImage:
            meta.mediaType = PGMetarMediaTypeImage;
            meta.image = [meta getImageAttributesForMedia: media];
            break;
        case kHPRMediaTypeVideo:
            meta.mediaType = PGMetarMediaTypeVideo;
            meta.video = [meta getVideoAttributesForMedia: media];
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
        
        location.altitude = [NSNumber numberWithDouble:media.location.altitude];
        location.name = media.locationName;
        
        if (location.name == nil) {
            location.name = [media.place name];
        }
        
        meta.location = location;
    }
    
    if (media.socialMediaImageUrl) {
        PGMetarSource *source = [[PGMetarSource alloc] init];
        source.uri = media.socialMediaImageUrl;
        source.owner = media.userName;

        meta.source = source;
    
        if (media.likes > 0 || media.comments > 0) {
            PGMetarSocialActivity *socialActivity = [[PGMetarSocialActivity alloc] init];
            socialActivity.likes = [NSNumber numberWithUnsignedInteger:media.likes];
            socialActivity.comments = [NSNumber numberWithUnsignedInteger:media.comments];
            PGMetarSocial *social = [[PGMetarSocial alloc] init];
            social.activity = socialActivity;
            
            meta.source.social = social;
        }        
    } else {
        PGMetarSource *source = [[PGMetarSource alloc] init];
        source.from = PGMetarSourceFromLocal;
        source.identifier = media.objectID;
        meta.source = source;
    }
    
    if (media.image.size.width > media.image.size.height) {
        meta.orientation = PGMetarMediaOrientationLandscape;
    } else {
        meta.orientation = PGMetarMediaOrientationPortrait;
    }
    
    return meta;
}

@end
