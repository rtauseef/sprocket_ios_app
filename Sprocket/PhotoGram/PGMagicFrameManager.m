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
#import "PGAurasmaMagicFrame.h"
#import "PGFrameItem.h"
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

+ (NSArray *)magicFramesArray {
    static NSArray *_frameArray;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _frameArray = @[
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"10dcae0f826b3890c991112a248d0538" name:@"BIRTHDAY Band" imageName:@"BIRTHDAY_Band"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"ba554181edfa094318c13bea0ae062fd" name:@"BIRTHDAY Bear Mail" imageName:@"BIRTHDAY_Bear_Mail"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"2ea77219f62018f32704346aa9441f5c" name:@"BIRTHDAY Dino" imageName:@"BIRTHDAY_Dino"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"d1561cef1bd5e35628c6df6faec7a04e" name:@"BIRTHDAY Multi" imageName:@"BIRTHDAY_Multi"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"6383f9d8b5572880b42d8fb4ec9fc980" name:@"BIRTHDAY Original Aurasma Band" imageName:@"BIRTHDAY_Original_Aurasma_Band"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"927813186ad9e7cff9c5531c3b3d870d" name:@"BIRTHDAY Selfie" imageName:@"BIRTHDAY_Selfie"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"a028f6b7a55b74972f3b237b9dc198e7" name:@"CHRISTMAS Aurasma Card" imageName:@"CHRISTMAS_Aurasma_Card"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"b868113193062f3acb9d673c192296c7" name:@"CHRISTMAS Fairy" imageName:@"CHRISTMAS_Fairy"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"2f0dce7fc022828ad2d4c1e322bc1239" name:@"CHRISTMAS Meerkats" imageName:@"CHRISTMAS_Meerkats"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"2d3a9c99bf9afb87fc490b65b6548656" name:@"CHRISTMAS Penguins" imageName:@"CHRISTMAS_Penguins"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"7bd54d0b1bb8f4dec97de2d460079e69" name:@"CHRISTMAS Rudolph" imageName:@"CHRISTMAS_Rudolph"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"340c0179c82096ed8b67425d63eaff61" name:@"CHRISTMAS Selfie" imageName:@"CHRISTMAS_Selfie"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"a048b06f2d30532e12b324aa940a9422" name:@"SUMMER Amazon" imageName:@"SUMMER_Amazon"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"3faa188ea23601827a359046cc686576" name:@"SUMMER BestWestern Selfie" imageName:@"SUMMER_BestWestern_Selfie"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"523d911b553847828de1df2ed3470ab4" name:@"SUMMER Soccer" imageName:@"SUMMER_Soccer"],
                        [PGAurasmaMagicFrame magicFrameWithAuraId:@"42918a730b2ed4b4b23dc0f31a92fdc1" name:@"SUMMER Turtles" imageName:@"SUMMER_Turtles"],
                        ];
    });
    return _frameArray;
    
}

+ (NSDictionary *)magicFramesDictionary {
    static NSDictionary *_magicFramesDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *framesMutableDict = [NSMutableDictionary dictionary];
        for (id magicFrame in [[self class] magicFramesArray]) {
            framesMutableDict[[PGFrameItem stickerNameWithName:((PGAurasmaMagicFrame *)magicFrame).name andPackageName:nil]] = magicFrame;
        }
        _magicFramesDict = [NSDictionary dictionaryWithDictionary:framesMutableDict];
    });
    return _magicFramesDict;
}

- (NSArray *)standardUSMagicFrames
{
    NSMutableArray *frameItemsMutable = [[NSMutableArray alloc] init];
    for (id item in [[self class] magicFramesArray]) {
        PGAurasmaMagicFrame *magicFrame = (PGAurasmaMagicFrame *)item;
        [frameItemsMutable addObject:[[PGFrameItem alloc] initWithName:magicFrame.name imageName:magicFrame.imageName
                                                        andPackageName:nil]];
    }
    // immutable copy
    return [frameItemsMutable copy];
}

- (NSArray<IMGLYFrame *> *)imglyFrames {
    NSMutableArray<IMGLYFrame *> *frames = [[NSMutableArray alloc] init];
    
    for (PGFrameItem *frame in self.frames) {
        [frames addObject:frame.imglyFrame];
    }
    
    return frames;
}

@end
