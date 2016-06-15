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

#import "PGTemplate.h"

@implementation PGTemplate

-(id)initWithPlistDictionary:(NSDictionary *)plistDict position:(NSUInteger)templatePosition
{
    self = [super init];
    if (self) {
        self.name = [plistDict objectForKey:@"Name"];
        self.position = templatePosition;
        
        NSArray *objects = @[ [plistDict objectForKey:@"File Name 4x5"],
                              [plistDict objectForKey:@"File Name 4x6"],
                              [plistDict objectForKey:@"File Name 5x7"],
                              [plistDict objectForKey:@"File Name 4x6"]];
        
        NSArray *keys = @[ [NSNumber numberWithInt:MPPaperSize4x5],
                           [NSNumber numberWithInt:MPPaperSize4x6],
                           [NSNumber numberWithInt:MPPaperSize5x7],
                           [NSNumber numberWithInt:MPPaperSize2x3]];
        
        self.fileNames = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
    }
    
    return self;
}

-(NSString *)fileNameForPaperSize:(MPPaperSize)size
{
    NSNumber *sizeObject = [NSNumber numberWithInt:size];
    return [self.fileNames objectForKey:sizeObject];
}

-(NSString *)pngFileName
{
    NSString *pngFilename = [self fileNameForPaperSize:MPPaperSize4x5];
    NSRange indexOfUnderscore = [pngFilename rangeOfString:@"_"];
    pngFilename = [pngFilename substringToIndex:indexOfUnderscore.location];

    return pngFilename;
}

@end
