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
