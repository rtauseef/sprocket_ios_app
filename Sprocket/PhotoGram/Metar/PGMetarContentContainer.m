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
        
        NSArray *pages = [dict objectForKey:@"pages"];
        
        if (pages) {
            NSMutableArray *tmpPages = [NSMutableArray array];
            
            for (NSDictionary *page in pages) {
                [tmpPages addObject:[[PGMetarPage alloc] initWithDictionary:page]];
            }
            
            self.pages = tmpPages;
        }
    }
    
    return self;
}

@end
