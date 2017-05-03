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

#import "PGFrameManager.h"
#import "NSLocale+Additions.h"

@interface PGFrameManager()

@property (nonatomic, strong) NSMutableArray *frames;

@end

@implementation PGFrameManager

+ (PGFrameManager *)sharedInstance
{
    static dispatch_once_t once;
    static PGFrameManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGFrameManager alloc] init];
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
    
    [self.frames addObjectsFromArray:[self standardUSFrames]];
}

- (NSArray *)standardUSFrames
{
    return @[
             [[PGFrameItem alloc] initWithName:@"Hearts Overlay" imageName:@"HeartsOverlayFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Sloppy" imageName:@"SloppyFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Rainbow" imageName:@"RainbowFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"White" imageName:@"WhiteFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Stars Overlay" imageName:@"StarsOverlayFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Polka Dots" imageName:@"PolkadotsFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Grey Shadow" imageName:@"GreyShadowFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Pink Triangle" imageName:@"PinkTriangleFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"White Rounded" imageName:@"WhiteRoundedFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Floral 2" imageName:@"Floral2Frame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Blue Watercolor" imageName:@"BlueWatercoloFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Floral Overlay" imageName:@"FloralOverlayFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Red" imageName:@"RedFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Gradient" imageName:@"GradientFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Turquoise" imageName:@"TurquoiseFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Dots Overlay" imageName:@"DotsOverlayFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Kraft" imageName:@"KraftFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"White Bar" imageName:@"WhiteBarFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"Pink Spray Paint" imageName:@"PinkSpraypaintFrame" andPackageName:nil],
             [[PGFrameItem alloc] initWithName:@"White Full" imageName:@"WhiteFullFrame" andPackageName:nil],
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
