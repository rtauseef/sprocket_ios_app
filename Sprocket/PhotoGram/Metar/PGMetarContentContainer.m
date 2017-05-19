//
//  PGContentContainer.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/18/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGMetarContentContainer.h"
#import "PGMetarPage.h"

@implementation PGMetarContentContainer

- (instancetype)initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    
    if (self) {
        if ([dict objectForKey:@"imagelist"]) {
            
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *innerDict in [dict objectForKey:@"imagelist"]) {
                [array addObject:[[PGMetarImageItem alloc] initWithDictionary: innerDict]];
            }
            
            self.imagelist = array;
        }
        
        NSString *updatedAt = [dict objectForKey:@"updatedAt"];
        
        if (updatedAt != nil) {
            self.updatedAt = [NSDate dateWithTimeIntervalSince1970:[updatedAt doubleValue]];
        }
        
        NSDictionary *pages = [dict objectForKey:@"pages"];
        
        if (pages) {
            
            NSMutableDictionary *tmpPages = [NSMutableDictionary dictionary];
            
            NSArray *allKeys = [pages allKeys];
            
            for (NSString *key in allKeys) {
                NSArray *allPages = [pages objectForKey:key];
                NSMutableArray *tmpAllPages = [NSMutableArray array];
                
                for (NSDictionary *page in allPages) {
                    PGMetarPage *metarPage = [[PGMetarPage alloc] initWithDictionary:page];
                    [tmpAllPages addObject:metarPage];
                }
                
                [tmpPages setObject:tmpAllPages forKey:key];
            }
            
            self.pages = tmpPages;
        }
    }
    
    return self;
}

@end
