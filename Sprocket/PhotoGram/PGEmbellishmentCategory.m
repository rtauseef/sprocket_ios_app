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

#import "PGEmbellishmentCategory.h"

@implementation PGEmbellishmentCategory

- (instancetype)initWithType:(PGEmbellishmentCategoryType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (NSString *)name
{
    switch (self.type) {
        case PGEmbellishmentCategoryTypeFont:
            return @"Font";
        case PGEmbellishmentCategoryTypeText:
            return @"Text";
        case PGEmbellishmentCategoryTypeSticker:
            return @"Sticker";
        case PGEmbellishmentCategoryTypeFilter:
            return @"Filter";
        case PGEmbellishmentCategoryTypeFrame:
            return @"Frame";
        case PGEmbellishmentCategoryTypeEdit:
            return @"Edit";
        default:
            return @"Unknown";
    }

}

@end
