//
//  PGPage.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarPage.h"

@implementation PGMetarIcon
- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    
    if (self) {
        self.thumb = [dict objectForKey:@"thumb"];
        self.original = [dict objectForKey:@"original"];
    }
    
    return self;
}
@end

@implementation PGMetarBlock
- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    
    if (self) {
        self.index = [dict objectForKey:@"index"];
        self.title = [dict objectForKey:@"title"];
        self.text = [dict objectForKey:@"text"];
    }
    
    return self;
}
@end

@implementation PGMetarPage
- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    
    if (self) {
        self.index = [dict objectForKey:@"index"];
        self.title = [dict objectForKey:@"title"];
        self.shortText = [dict objectForKey:@"shortText"];
        self.text = [dict objectForKey:@"text"];
        
        if ([dict objectForKey:@"location"] != nil) {
            PGMetarLocation *location = [[PGMetarLocation alloc] initWithDictionary:[dict objectForKey:@"location"]];
            self.location = location;
        }
        
        if ([dict objectForKey:@"icon"] != nil) {
            self.icon = [[PGMetarIcon alloc] initWithDictionary:[dict objectForKey:@"icon"]];
        }
        
        self.from = [dict objectForKey:@"from"];
        
        NSArray *blocks = [dict objectForKey:@"blocks"];
        
        if (blocks != nil) {
            NSMutableArray *tmpBlocks = [NSMutableArray array];
            
            for (NSDictionary* block in blocks) {
                [tmpBlocks addObject:[[PGMetarBlock alloc] initWithDictionary:block]];
            }
            
            self.blocks = tmpBlocks;
        }
        
        NSArray *images = [dict objectForKey:@"images"];
        
        if (images) {
            NSMutableArray *tmpImages = [NSMutableArray array];
            
            for (NSDictionary* image in images) {
                if (image && [image isKindOfClass:[NSDictionary class]]) {
                    PGMetarIcon *icon = [[PGMetarIcon alloc] initWithDictionary:image];
                
                    if (icon.original && icon.thumb) {
                        [tmpImages addObject:icon];
                    }
                }
            }
            
            self.images = tmpImages;
        }
        
        NSArray *externalLinks = [dict objectForKey:@"externalLinks"];
        
        if (externalLinks) {
            NSMutableArray *tmpexternalLinks = [NSMutableArray array];
            
            for (NSString* externalLink in externalLinks) {
                [tmpexternalLinks addObject:externalLink];
            }
            
            self.externalLinks = tmpexternalLinks;
        }
    }
    
    return self;
}
@end
