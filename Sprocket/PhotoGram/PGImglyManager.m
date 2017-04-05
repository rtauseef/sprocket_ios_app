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
#import "PGStickerManager.h"
#import "PGFrameManager.h"
#import "UIColor+Style.h"

#define kImglyColorCellHeightAdjustment 18

@interface PGImglyManager() <IMGLYStickersDataSourceProtocol, IMGLYFramesDataSourceProtocol>

@end

@implementation PGImglyManager

- (IMGLYConfiguration *)imglyConfigurationWithEmbellishmentManager:(PGEmbellishmentMetricsManager *)embellishmentMetricsManager
{
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
            
            [photoEditorBuilder setApplyButtonConfigurationClosure:^(UIButton * _Nonnull applyButton) {
                // Workaround to fix saving image bug on slower devices.
                applyButton.enabled = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    applyButton.enabled = YES;
                });
            }];
            
            PGEmbellishmentMetric *autofixMetric = [[PGEmbellishmentMetric alloc] initWithName:@"Auto-fix" andCategoryType:PGEmbellishmentCategoryTypeEdit];
            
            [photoEditorBuilder setActionButtonConfigurationClosure:^(IMGLYIconCaptionCollectionViewCell * _Nonnull cell, enum PhotoEditorAction action) {
                cell.tintColor = [UIColor HPGrayBackgroundColor];
                cell.imageView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
                cell.imageView.highlightedImage = nil;
                cell.captionLabel.text = nil;

                switch (action) {
                    case PhotoEditorActionMagic: {
                        cell.imageView.highlightedImage = [[UIImage imageNamed:@"auto_enhance_On"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                        cell.imageView.image = [[UIImage imageNamed:@"auto_enhance_Off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                        cell.accessibilityIdentifier = @"editMagic";
                        
                        if ([embellishmentMetricsManager hasEmbellishmentMetric:autofixMetric]) {
                            cell.imageView.highlighted = YES;
                        } else {
                            cell.imageView.highlighted = NO;
                        }
                        
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
            }];

            [photoEditorBuilder setPhotoEditorActionSelectedClosure:^(enum PhotoEditorAction action) {
                if (action == PhotoEditorActionMagic) {
                    if ([embellishmentMetricsManager hasEmbellishmentMetric:autofixMetric]) {
                        [embellishmentMetricsManager removeEmbellishmentMetric:autofixMetric];
                    } else {
                        [embellishmentMetricsManager addEmbellishmentMetric:autofixMetric];
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
                PGEmbellishmentMetric *stickerMetric = [[PGEmbellishmentMetric alloc] initWithName:[self stickerNameFromImglySticker:sticker] andCategoryType:PGEmbellishmentCategoryTypeSticker];

                [embellishmentMetricsManager addEmbellishmentMetric:stickerMetric];
            };
            
            stickerBuilder.removedStickerClosure = ^(IMGLYSticker *sticker) {
                PGEmbellishmentMetric *stickerMetric = [[PGEmbellishmentMetric alloc] initWithName:[self stickerNameFromImglySticker:sticker] andCategoryType:PGEmbellishmentCategoryTypeSticker];
                
                [embellishmentMetricsManager removeEmbellishmentMetric:stickerMetric];
            };
        }];
        
        [builder configureFrameToolController:^(IMGLYFrameToolControllerOptionsBuilder * _Nonnull frameToolBuilder) {
            frameToolBuilder.framesDataSource = self;
            frameToolBuilder.selectedFrameClosure = ^(IMGLYFrame *frame) {
                NSString *frameName = @"NoFrame";
                if (nil != frame) {
                    frameName = frame.accessibilityText;
                    PGFrameItem *frameItem = [[PGFrameManager sharedInstance] frameByAccessibilityText:frameName];
                    if (nil != frameItem) {
                        frameName = frameItem.name;
                    }
                }
                
                [embellishmentMetricsManager clearFramesEmbellishmentMetric];
                [embellishmentMetricsManager addEmbellishmentMetric:[[PGEmbellishmentMetric alloc] initWithName:frameName andCategoryType:PGEmbellishmentCategoryTypeFrame]];
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
                [embellishmentMetricsManager addEmbellishmentMetric:[[PGEmbellishmentMetric alloc] initWithName:filter.displayName andCategoryType:PGEmbellishmentCategoryTypeFilter]];
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
        completionBlock([PGStickerManager sharedInstance].stickersCount, nil);
    }
}

- (void)thumbnailAndLabelAtIndex:(NSInteger)index completionBlock:(void (^)(UIImage * _Nullable, NSString * _Nullable, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        PGStickerItem *sticker = [[PGStickerManager sharedInstance] stickerByIndex:index];
        completionBlock(sticker.thumbnailImage, nil, nil);
    }
}

- (void)stickerAtIndex:(NSInteger)index completionBlock:(void (^)(IMGLYSticker * _Nullable, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        PGStickerItem *sticker = [[PGStickerManager sharedInstance] stickerByIndex:index];
        IMGLYSticker *imglySticker = [[IMGLYSticker alloc] initWithImage:sticker.stickerImage thumbnail:sticker.thumbnailImage accessibilityText:sticker.accessibilityText];
        completionBlock(imglySticker, nil);
    }
}

#pragma mark - IMGLYFramesDataSourceProtocol

- (void)frameCountForRatio:(float)ratio completionBlock:(void (^)(NSInteger, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        completionBlock([PGFrameManager sharedInstance].framesCount, nil);
    }
}

- (void)thumbnailAndLabelAtIndex:(NSInteger)index forRatio:(float)ratio completionBlock:(void (^)(UIImage * _Nullable, NSString * _Nullable, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        PGFrameItem *frame = [[PGFrameManager sharedInstance] frameByIndex:index];
        completionBlock(frame.thumbnailImage, frame.accessibilityText, nil);
    }
}

- (void)frameAtIndex:(NSInteger)index forRatio:(float)ratio completionBlock:(void (^)(IMGLYFrame * _Nullable, NSError * _Nullable))completionBlock
{
    if (completionBlock) {
        CGFloat ratio = 2.0/3.0;
        
        PGFrameItem *frame = [[PGFrameManager sharedInstance] frameByIndex:index];
        IMGLYFrameInfoRecord *info = [[IMGLYFrameInfoRecord alloc] init];
        
        info.accessibilityText = frame.accessibilityText;
        IMGLYFrame *imglyFrame = [[IMGLYFrame alloc] initWithInfo:info];
        
        [imglyFrame addImage:frame.frameImage forRatio:ratio];
        [imglyFrame addThumbnail:frame.thumbnailImage forRatio:ratio];
        
        completionBlock(imglyFrame, nil);
    }
}

#pragma mark - Analytics

- (NSString *)stickerNameFromImglySticker:(IMGLYSticker *)sticker
{
    NSString *stickerName = sticker.accessibilityText;
    PGStickerItem *stickerItem = [[PGStickerManager sharedInstance] stickerByAccessibilityText:stickerName];
    if (nil != stickerItem) {
        stickerName = stickerItem.name;
    }

    return stickerName;
}

@end
