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

#import "PGFrameItem.h"
#import "NSLocale+Additions.h"

@interface PGFrameItem () <IMGLYFrameBuilderProtocol>

@end

@implementation PGFrameItem

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName andPackageName:(NSString *)packageName
{
    self = [super init];
    if (self) {
        NSString *stickerName = nil;
        if (packageName) {
            stickerName = [NSString stringWithFormat:@"%@ %@ Frame", packageName, name];
        } else {
            stickerName = [NSString stringWithFormat:@"%@ Frame", name];
        }
        
        self.name = stickerName;
        self.accessibilityText = stickerName;
        self.imageName = imageName;
    }
    return self;
}

- (UIImage *)thumbnailImage
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_TN", self.imageName]];
}

- (NSURL *)thumbnailURL {
    return [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@_TN", self.imageName] withExtension:@"png"];
}

- (UIImage *)frameImage
{
    return [UIImage imageNamed:self.imageName];
}

- (IMGLYFrame *)imglyFrame {
    IMGLYFrame *imglyFrame = [[IMGLYFrame alloc] initWithFrameBuilder:self
                                                        relativeScale:2.0/3.0
                                                         thumbnailURL:[self thumbnailURL]
                              ];

    imglyFrame.accessibilityLabel = self.name;

    return imglyFrame;
}


#pragma mark - IMGLYFrameBuilderProtocol

- (UIImage *)buildWithSize:(CGSize)size relativeScale:(CGFloat)relativeScale {
    return [self frameImage];
}

@end
