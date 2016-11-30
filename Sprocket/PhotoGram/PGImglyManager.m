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

#import "PGImglyManager.h"
#import "PGStickerItem.h"
#import "PGFrameItem.h"
#import "UIColor+Style.h"

#define kImglyColorCellHeightAdjustment 18

static const NSString *kCategoryMetricColumn = @"category";
static const NSString *kNameMetricColumn = @"name";

static NSString *kMetricCategoryFont = @"Font";
static NSString *kMetricCategoryText = @"Text";
static NSString *kMetricCategorySticker = @"Sticker";
static NSString *kMetricCategoryFilter = @"Filter";
static NSString *kMetricCategoryFrame = @"Frame";

@interface PGImglyManager() <IMGLYStickersDataSourceProtocol, IMGLYFramesDataSourceProtocol>

typedef enum {
    PGEmbellishmentCategoryFont,
    PGEmbellishmentCategoryText,
    PGEmbellishmentCategorySticker,
    PGEmbellishmentCategoryFilter,
    PGEmbellishmentCategoryFrame,
    PGEmbellishmentCategoryEdit
} PGEmbellishmentCategory;

@property (strong, nonatomic) NSMutableArray *analytics;

@end

@implementation PGImglyManager

- (IMGLYConfiguration *)imglyConfiguration
{
    self.analytics = [[NSMutableArray alloc] init];
    
    IMGLYConfiguration *configuration = [[IMGLYConfiguration alloc] initWithBuilder:^(IMGLYConfigurationBuilder * _Nonnull builder) {
        
        builder.contextMenuBackgroundColor = [UIColor HPGrayColor];
        
        [builder configureToolStackController:^(IMGLYToolStackControllerOptionsBuilder * _Nonnull stackBuilder) {
            stackBuilder.mainToolbarBackgroundColor = [UIColor HPGrayColor];
            stackBuilder.secondaryToolbarBackgroundColor = [UIColor clearColor];
        }];
        
        [builder configurePhotoEditorViewController:^(IMGLYPhotoEditViewControllerOptionsBuilder * _Nonnull photoEditorBuilder) {
            photoEditorBuilder.allowedPhotoEditorActionsAsNSNumbers = @[
                                                                        @(PhotoEditorActionMagic),
                                                                        @(PhotoEditorActionFilter),
                                                                        @(PhotoEditorActionFrame),
                                                                        @(PhotoEditorActionSticker),
                                                                        @(PhotoEditorActionText),
                                                                        @(PhotoEditorActionCrop)
                                                                        ];
            photoEditorBuilder.frameScaleMode = UIViewContentModeScaleToFill;
            photoEditorBuilder.backgroundColor = [UIColor HPGrayColor];
            photoEditorBuilder.allowsPreviewImageZoom = NO;
            
            [photoEditorBuilder setActionButtonConfigurationClosure:^(IMGLYIconCaptionCollectionViewCell * _Nonnull cell, enum PhotoEditorAction action) {
                switch (action) {
                    case PhotoEditorActionMagic: {
                        cell.imageView.image = [UIImage imageNamed:@"editMagic"];
                        cell.imageView.tintColor = [UIColor whiteColor];

                        cell.accessibilityIdentifier = @"editMagic";
                        break;
                    }
                    case PhotoEditorActionFilter:
                        cell.imageView.image = [UIImage imageNamed:@"editFilters"];
                        cell.accessibilityIdentifier = @"editFilters";
                        break;
                    case PhotoEditorActionFrame:
                        cell.imageView.image = [UIImage imageNamed:@"editFrame"];
                        cell.accessibilityIdentifier = @"editFrame";
                        break;
                    case PhotoEditorActionSticker:
                        cell.imageView.image = [UIImage imageNamed:@"editSticker"];
                        cell.accessibilityIdentifier = @"editSticker";
                        break;
                    case PhotoEditorActionText:
                        cell.imageView.image = [UIImage imageNamed:@"editText"];
                        cell.accessibilityIdentifier = @"editText";
                        break;
                    case PhotoEditorActionCrop:
                        cell.imageView.image = [UIImage imageNamed:@"editCrop"];
                        cell.accessibilityIdentifier = @"editCrop";
                        break;
                    default:
                        break;
                }
                
                cell.captionLabel.text = nil;
            }];

            [photoEditorBuilder setPhotoEditorActionSelectedClosure:^(enum PhotoEditorAction action) {
                if (action == PhotoEditorActionMagic) {
                    NSString *embellishmentName = @"Auto-fix";

                    if ([self hasEmbellishmentMetric:PGEmbellishmentCategoryEdit name:embellishmentName]) {
                        [self removeEmbellishmentMetric:PGEmbellishmentCategoryEdit name:embellishmentName];
                    } else {
                        [self addEmbellishmentMetric:PGEmbellishmentCategoryEdit name:embellishmentName];
                    }
                }
            }];
        }];
        
        NSArray *photoEffectsArray = [NSArray arrayWithObjects:
                                      [[IMGLYPhotoEffect alloc] initWithIdentifier:@"None" CIFilterName:nil lutURL:nil displayName:@"None" options:nil],
                                      [self imglyFilterByName:@"AD1920"],
                                      [self imglyFilterByName:@"Candy"],
                                      [self imglyFilterByName:@"Lomo"],
                                      [self imglyFilterByName:@"Litho"],
                                      [self imglyFilterByName:@"Quozi"],
                                      [self imglyFilterByName:@"SepiaHigh"],
                                      [self imglyFilterByName:@"Sunset"],
                                      [self imglyFilterByName:@"Twilight"],
                                      [self imglyFilterByName:@"Breeze"],
                                      [self imglyFilterByName:@"Blues"],
                                      [self imglyFilterByName:@"Dynamic"],
                                      [self imglyFilterByName:@"Orchid"],
                                      [self imglyFilterByName:@"Pale"],
                                      [self imglyFilterByName:@"80s"],
                                      [self imglyFilterByName:@"Pro400"],
                                      [self imglyFilterByName:@"Steel"],
                                      [self imglyFilterByName:@"Creamy"],
                                      nil];
        
        IMGLYPhotoEffect.allEffects = photoEffectsArray;

        [builder configureStickerToolController:^(IMGLYStickerToolControllerOptionsBuilder * _Nonnull stickerBuilder) {
            stickerBuilder.stickersDataSource = self;
            
            stickerBuilder.addedStickerClosure = ^(IMGLYSticker *sticker) {
                [self addEmbellishmentMetric:PGEmbellishmentCategorySticker name:sticker.accessibilityText];
            };
            
            stickerBuilder.removedStickerClosure = ^(IMGLYSticker *sticker) {
                [self removeEmbellishmentMetric:PGEmbellishmentCategorySticker name:sticker.accessibilityText];
            };
        }];
        
        [builder configureFrameToolController:^(IMGLYFrameToolControllerOptionsBuilder * _Nonnull frameToolBuilder) {
            frameToolBuilder.framesDataSource = self;
            frameToolBuilder.selectedFrameClosure = ^(IMGLYFrame *frame) {
                NSString *frameName = @"NoFrame";
                if (nil != frame) {
                    frameName = frame.accessibilityText;
                }
                [self addEmbellishmentMetric:PGEmbellishmentCategoryFrame name:frameName];
            };
        }];
        
        [builder configureCropToolController:^(IMGLYCropToolControllerOptionsBuilder * _Nonnull cropToolBuilder) {
            IMGLYCropRatio *cropRatio2x3 = [[IMGLYCropRatio alloc] initWithRatio:[NSNumber numberWithFloat:2.0/3.0] title:@"2:3" accessibilityLabel:@"2:3 crop ratio" icon:[UIImage imageNamed:@"imglyIconCrop2x3"]];
            IMGLYCropRatio *cropRatio3x2 = [[IMGLYCropRatio alloc] initWithRatio:[NSNumber numberWithFloat:3.0/2.0] title:@"3:2" accessibilityLabel:@"3:2 crop ratio" icon:[UIImage imageNamed:@"imglyIconCrop3x2"]];
            cropToolBuilder.allowedCropRatios = @[
                                                  cropRatio2x3,
                                                  cropRatio3x2 ];
        }];
        
        // The textField configuration
        [builder configureTextToolController:^(IMGLYTextToolControllerOptionsBuilder * _Nonnull textToolBuilder) {
            [textToolBuilder setTitle:@" "];
            
            
            [textToolBuilder setTextViewConfigurationClosure:^(UITextView * _Nonnull textView) {
                static NSInteger numTextFields = 0;
                
                [textView setKeyboardAppearance:UIKeyboardAppearanceDark];
                [textView setTextAlignment:NSTextAlignmentCenter];
                [textView setTintColor:[UIColor whiteColor]];
                [textView setAccessibilityIdentifier:[NSString stringWithFormat:@"txtField%ld", (long)numTextFields]];
            }];
        }];
        
        [builder configureFilterToolController:^(IMGLYFilterToolControllerOptionsBuilder * _Nonnull filterBuilder) {
            [filterBuilder setFilterCellConfigurationClosure:^(IMGLYFilterCollectionViewCell * _Nonnull cell, IMGLYPhotoEffect * _Nonnull effect) {
                [cell.captionLabel removeFromSuperview];
            }];
            
            filterBuilder.filterSelectedClosure = ^(IMGLYPhotoEffect *filter) {
                [self addEmbellishmentMetric:PGEmbellishmentCategoryFilter name:filter.displayName];
            };
        }];
        
        // The initial text font and color modification screen (created after entering text into the textfield
        [builder configureTextOptionsToolController:^(IMGLYTextOptionsToolControllerOptionsBuilder * _Nonnull textOptionsBuilder) {
            [textOptionsBuilder setTitle:@" "];
            
            [textOptionsBuilder setContextActionConfigurationClosure:^(IMGLYContextMenuAction * _Nonnull menuAction, enum TextContextAction contextAction) {
                
                // Unfortunately, the image property on menuAction is readOnly... so, we stay with the default icons
            }];
            
            [textOptionsBuilder setActionButtonConfigurationClosure:^(UICollectionViewCell * _Nonnull cell, enum TextAction textAction) {
                
                UIImageView *imageView = nil;
                
                switch (textAction) {
                    case TextActionSelectFont:
                        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imglyIconFont"]];
                        break;
                        
                    case TextActionSelectColor:
                        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imglyIconColor"]];
                        break;
                        
                    case TextActionSelectBackgroundColor:
                        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imglyIconBackgroundColor"]];
                        break;
                        
                    default:
                        break;
                };
                
                if (nil != imageView) {
                    CGFloat inverseAspectRatio = imageView.image.size.height / imageView.image.size.width;
                    
                    [cell.subviews[0] removeFromSuperview];
                    [cell addSubview:imageView];
                    
                    CGRect frame = imageView.frame;
                    frame.size.width = cell.frame.size.width - 20;
                    frame.size.height = frame.size.width * inverseAspectRatio;
                    frame.origin.x = (cell.frame.size.width - frame.size.width)/2;
                    frame.origin.y = (cell.frame.size.height - frame.size.height)/2;
                    imageView.frame = frame;
                }
            }];
            
            textOptionsBuilder.textActionSelectedClosure = ^(TextAction textAction) {
                // called for selectFont, selectColor, and selectBackgroundColor
               MPLogDebug(@"text action: %ld", (long)textAction);
            };
        }];
        
        // The screen for both text color and background color
        [builder configureTextColorToolController:^(IMGLYTextColorToolControllerOptionsBuilder * _Nonnull textColorToolBuilder) {
            [textColorToolBuilder setTitle:@" "];
            
            [textColorToolBuilder setTextColorActionButtonConfigurationClosure:^(IMGLYColorCollectionViewCell * _Nonnull cell, UIColor * _Nonnull color, NSString * _Nonnull title) {
                CGRect cellRect = cell.frame;
                cellRect.size.height = cellRect.size.width + kImglyColorCellHeightAdjustment;
                cell.frame = cellRect;
                cell.colorView.layer.cornerRadius = cellRect.size.width / 2;
                cell.colorView.layer.masksToBounds = YES;
            }];
        }];
        
        // The screen for text font
        [builder configureTextFontToolController:^(IMGLYTextFontToolControllerOptionsBuilder * _Nonnull textFontToolBuilder) {
            [textFontToolBuilder setTitle:@" "];
            
            [textFontToolBuilder setActionButtonConfigurationClosure:^(IMGLYLabelCaptionCollectionViewCell * _Nonnull cell, NSString * _Nonnull label) {
                cell.captionLabel.text = nil;
            }];
            
            textFontToolBuilder.textFontActionSelectedClosure = ^(NSString *font) {
                // Never called :-(
            };
        }];
    }];
    
    return configuration;
}

- (IMGLYPhotoEffect *)imglyFilterByName:(NSString *)name {
    NSBundle *photoEffectBundle = [NSBundle bundleForClass:[IMGLYPhotoEffect self]];
    NSURL *k2Url = [photoEffectBundle URLForResource:name withExtension:@"png" subdirectory:@"imglyKit.bundle"];
    
    return [[IMGLYPhotoEffect alloc] initWithIdentifier:name lutURL:k2Url displayName:name];
}

#pragma mark - IMGLY Stickers

- (void)stickerCountWith:(void (^)(NSInteger, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        completionBlock(PGStickerItemsCount, nil);
    }
}

- (void)thumbnailAndLabelAtIndex:(NSInteger)index completionBlock:(void (^)(UIImage * _Nullable, NSString * _Nullable, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        PGStickerItem *sticker = [PGStickerItem stickerItemByIndex:index];
        completionBlock(sticker.thumbnailImage, nil, nil);
    }
}

- (void)stickerAtIndex:(NSInteger)index completionBlock:(void (^)(IMGLYSticker * _Nullable, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        PGStickerItem *sticker = [PGStickerItem stickerItemByIndex:index];
        IMGLYSticker *imglySticker = [[IMGLYSticker alloc] initWithImage:sticker.stickerImage thumbnail:sticker.thumbnailImage accessibilityText:sticker.imageName];
        completionBlock(imglySticker, nil);
    }
}

#pragma mark - IMGLYFramesDataSourceProtocol

- (void)frameCountForRatio:(float)ratio completionBlock:(void (^)(NSInteger, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        completionBlock(PGFrameItemsCount, nil);
    }
}

- (void)thumbnailAndLabelAtIndex:(NSInteger)index forRatio:(float)ratio completionBlock:(void (^)(UIImage * _Nullable, NSString * _Nullable, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        PGFrameItem *frame = [PGFrameItem frameItemByIndex:index];
        completionBlock(frame.thumbnailImage, frame.accessibilityText, nil);
    }
}

- (void)frameAtIndex:(NSInteger)index forRatio:(float)ratio completionBlock:(void (^)(IMGLYFrame * _Nullable, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        CGFloat ratio = 2.0/3.0;
        
        PGFrameItem *frame = [PGFrameItem frameItemByIndex:index];
        IMGLYFrameInfoRecord *info = [[IMGLYFrameInfoRecord alloc] init];
        
        info.accessibilityText = frame.accessibilityText;
        IMGLYFrame *imglyFrame = [[IMGLYFrame alloc] initWithInfo:info];
        
        [imglyFrame addImage:frame.frameImage forRatio:ratio];
        [imglyFrame addThumbnail:frame.thumbnailImage forRatio:ratio];
        
        completionBlock(imglyFrame, nil);
    }
}

#pragma mark - Analytics

- (NSString *)categoryName:(PGEmbellishmentCategory)category
{
    NSString *strCategory = @"";
    switch (category) {
        case PGEmbellishmentCategoryFont:
            strCategory = kMetricCategoryFont;
            break;
            
        case PGEmbellishmentCategoryText:
            strCategory = kMetricCategoryText;
            break;
            
        case PGEmbellishmentCategorySticker:
            strCategory = kMetricCategorySticker;
            break;
            
        case PGEmbellishmentCategoryFilter:
            strCategory = kMetricCategoryFilter;
            break;
            
        case PGEmbellishmentCategoryFrame:
            strCategory = kMetricCategoryFrame;
            break;
            
        default:
            strCategory = @"Unknown";
            break;
    }
    
    return strCategory;
}

- (BOOL)hasEmbellishmentMetric:(PGEmbellishmentCategory)category name:(NSString *)name
{
    BOOL metricFound = NO;
    NSString *strCategory = [self categoryName:category];

    for (NSDictionary *metric in self.analytics) {
        if ([strCategory isEqualToString:metric[kCategoryMetricColumn]] &&
            [name isEqualToString:metric[kNameMetricColumn]]) {
            metricFound = YES;
            break;
        }
    }

    return metricFound;
}

- (void)removeEmbellishmentCategory:(PGEmbellishmentCategory)category
{
    NSString *strCategory = [self categoryName:category];
    
    NSDictionary *objectToRemove = nil;
    for (NSDictionary *metric in self.analytics) {
        if ([strCategory isEqualToString:[metric objectForKey:kCategoryMetricColumn]]) {
            objectToRemove = metric;
            break;
        }
    }
    
    if (nil != objectToRemove) {
        [self.analytics removeObject:objectToRemove];
    }
}

- (void)removeEmbellishmentMetric:(PGEmbellishmentCategory)category name:(NSString *)name
{
    NSString *strCategory = [self categoryName:category];
    
    NSDictionary *objectToRemove = nil;
    for (NSDictionary *metric in self.analytics) {
        if ([strCategory isEqualToString:[metric objectForKey:kCategoryMetricColumn]] &&
            [name isEqualToString:[metric objectForKey:kNameMetricColumn]]) {
            objectToRemove = metric;
            break;
        }
    }
    
    if (nil != objectToRemove) {
        [self.analytics removeObject:objectToRemove];
    }
}

- (void)addEmbellishmentMetric:(PGEmbellishmentCategory)category name:(NSString *)name
{
    NSString *strCategory = [self categoryName:category];
    
    switch (category) {
        case PGEmbellishmentCategoryFont:
            break;
            
        case PGEmbellishmentCategoryText:
            break;
            
        case PGEmbellishmentCategorySticker:
            break;
            
        case PGEmbellishmentCategoryFilter:
            [self removeEmbellishmentCategory:category];
            break;
            
        case PGEmbellishmentCategoryFrame:
            [self removeEmbellishmentCategory:category];
            break;
            
        default:
            strCategory = @"Unknown";
            break;
    }
    
    NSDictionary *metric = @{kCategoryMetricColumn : strCategory,
                             kNameMetricColumn     : name};
    
    [self.analytics addObject:metric];
    
    MPLogDebug(@"Embellishment Analytics: %@", self.analytics);
}

- (NSString *)analyticsString
{
    NSString *finalMetric = @"";
    NSCharacterSet *trimSet = [NSCharacterSet characterSetWithCharactersInString:@", "];
    
    for (NSDictionary *metric in self.analytics) {
        if (finalMetric.length > 0) {
            finalMetric = [finalMetric stringByAppendingString:@";"];
        }
        
        NSString *metricString = @"";
        for (NSString *key in [metric allKeys]) {
            metricString = [metricString stringByAppendingFormat:@", %@:%@", key, [metric objectForKey:key]];
        }
        metricString = [metricString stringByTrimmingCharactersInSet:trimSet];
        
        finalMetric = [finalMetric stringByAppendingString:metricString];
    }
    
    return finalMetric;
}

@end
