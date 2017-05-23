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

#import "PGMagicFrameManager.h"
#import "NSLocale+Additions.h"

@interface PGMagicFrameManager()

@property (nonatomic, strong) NSMutableArray *frames;

@end

@implementation PGMagicFrameManager

+ (PGMagicFrameManager *)sharedInstance
{
    static dispatch_once_t once;
    static PGMagicFrameManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGMagicFrameManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.frames = [NSMutableArray array];
    
    [self.frames addObjectsFromArray:[self standardUSMagicFrames]];
}

- (NSArray *)standardUSMagicFrames
{
    return @[
             [[PGFrameItem alloc] initWithName:@"BIRTHDAY Band" imageName:@"BIRTHDAY_Band" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"BIRTHDAY Bear Mail" imageName:@"BIRTHDAY_Bear_Mail" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"BIRTHDAY Dino" imageName:@"BIRTHDAY_Dino" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"BIRTHDAY Multi" imageName:@"BIRTHDAY_Multi" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"BIRTHDAY Original Aurasma Band" imageName:@"BIRTHDAY_Original_Aurasma_Band" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"BIRTHDAY Selfie" imageName:@"BIRTHDAY_Selfie" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"CHRISTMAS Aurasma Card" imageName:@"CHRISTMAS_Aurasma_Card" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"CHRISTMAS Fairy" imageName:@"CHRISTMAS_Fairy" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"CHRISTMAS Meerkats" imageName:@"CHRISTMAS_Meerkats" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"CHRISTMAS Penguins" imageName:@"CHRISTMAS_Penguins" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"CHRISTMAS Rudolph" imageName:@"CHRISTMAS_Rudolph" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"CHRISTMAS Selfie" imageName:@"CHRISTMAS_Selfie" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"SUMMER Amazon" imageName:@"SUMMER_Amazon" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"SUMMER BestWestern Selfie" imageName:@"SUMMER_BestWestern_Selfie" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"SUMMER Soccer" imageName:@"SUMMER_Soccer" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"SUMMER Turtles" imageName:@"SUMMER_Turtles" andPackageName:nil],
             ];
}

- (NSArray<IMGLYFrame *> *)imglyFrames {
    NSMutableArray<IMGLYFrame *> *frames = [[NSMutableArray alloc] init];
    
    for (PGFrameItem *frame in self.frames) {
        [frames addObject:frame.imglyFrame];
    }
    
    return frames;
}

@end
