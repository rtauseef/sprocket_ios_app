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

static NSString * const kImglyMenuItemMagic = @"Magic";
static NSString * const kImglyMenuItemFilter = @"Filter";
static NSString * const kImglyMenuItemFrame = @"Frame";
static NSString * const kImglyMenuItemSticker = @"Sticker";
static NSString * const kImglyMenuItemText = @"Text";
static NSString * const kImglyMenuItemCrop = @"Crop";

@interface PGImglyManager() //<IMGLYStickersDataSourceProtocol, IMGLYFramesDataSourceProtocol>

@property (nonatomic, strong) NSDictionary *menuItems;

@property (nonatomic, copy) void (^titleBlock)(UIView * _Nonnull view);
@property (nonatomic, copy) void (^colorBlock)(IMGLYColorCollectionViewCell * _Nonnull cell, UIColor * _Nonnull color, NSString * _Nonnull colorName);

@end

@implementation PGImglyManager

- (instancetype)init {
    self = [super init];

    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURL *licenseURL = [[NSBundle mainBundle] URLForResource:@"imgly_license" withExtension:@""];
            [PESDK unlockWithLicenseAt:licenseURL];
        });
    }

    return self;
}

- (NSArray<IMGLYBoxedMenuItem *> *)menuItemsWithConfiguration:(IMGLYConfiguration *)configuration {

    IMGLYBoxedMenuItem *magicItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemMagic
                                                                         icon:[UIImage imageNamed:@"ic_magic_48pt"]
                                                                       action:^IMGLYBoxedPhotoEditModel * _Nonnull(IMGLYBoxedPhotoEditModel * _Nonnull photoEditModel) {
                                                                           photoEditModel.isAutoEnhancementEnabled = !photoEditModel.isAutoEnhancementEnabled;
                                                                           return photoEditModel;
                                                                       }
                                                                        state:nil];

    IMGLYBoxedMenuItem *filterItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemFilter
                                                                          icon:[UIImage imageNamed:@"ic_filter_48pt"]
                                                                          tool:[[IMGLYFilterToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *frameItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemFrame
                                                                         icon:[UIImage imageNamed:@"ic_frame_48pt"]
                                                                         tool:[[IMGLYFrameToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *stickerItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemSticker
                                                                           icon:[UIImage imageNamed:@"ic_sticker_48pt"]
                                                                           tool:[[IMGLYStickerToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *textItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemText
                                                                        icon:[UIImage imageNamed:@"ic_text_48pt"]
                                                                        tool:[[IMGLYTextToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *cropItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemCrop
                                                                        icon:[UIImage imageNamed:@"ic_crop_48pt"]
                                                                        tool:[[IMGLYTransformToolController alloc] initWithConfiguration:configuration]];

    return @[
             magicItem,
             filterItem,
             frameItem,
             stickerItem,
             textItem,
             cropItem
             ];
}

- (NSArray<IMGLYPhotoEffect *> *)photoEffects {
    NSArray *photoEffectsArray = @[
                                   [[IMGLYPhotoEffect alloc] initWithIdentifier:@"None" ciFilterName:nil lutURL:nil displayName:@"None" options:nil],
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
                                   [self imglyFilterByName:@"Creamy"]
                                   ];

    IMGLYPhotoEffect.allEffects = photoEffectsArray;

    return photoEffectsArray;
}

- (NSArray<IMGLYFont *> *)fonts {

    NSArray<IMGLYFont *> *fonts = @[
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"Aleo-Bold" ofType:@"otf"]
                                                        displayName:@" " fontName:@"Aleo-Bold"],
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"BERNIERRegular-Regular" ofType:@"otf"]
                                                        displayName:@" " fontName:@"BERNIERRegular-Regular"],
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"Blogger Sans-Light" ofType:@"otf"]
                                                        displayName:@" " fontName:@"Blogger Sans-Light"],
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"Cheque-Regular" ofType:@"otf"]
                                                        displayName:@" " fontName:@"Cheque-Regular"],
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"FiraSans-Regular" ofType:@"ttf"]
                                                        displayName:@" " fontName:@"FiraSans-Regular"],
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"Gagalin-Regular" ofType:@"otf"]
                                                        displayName:@" " fontName:@"Gagalin-Regular"],
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"Hagin Caps Thin" ofType:@"otf"]
                                                        displayName:@" " fontName:@"Hagin Caps Thin"],
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"Panton-BlackitalicCaps" ofType:@"otf"]
                                                        displayName:@" " fontName:@"Panton-BlackitalicCaps"],
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"Panton-LightitalicCaps" ofType:@"otf"]
                                                        displayName:@" " fontName:@"Panton-LightitalicCaps"],
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"Perfograma" ofType:@"otf"]
                                                        displayName:@" " fontName:@"Perfograma"],
                                    [[IMGLYFont alloc] initWithPath:[[NSBundle imglyKitBundle] pathForResource:@"Summer Font Light" ofType:@"otf"]
                                                        displayName:@" " fontName:@"Summer Font Light"],

                                    [[IMGLYFont alloc] initWithDisplayName:@" " fontName:@"AmericanTypewriter"],
                                    [[IMGLYFont alloc] initWithDisplayName:@" " fontName:@"Baskerville"],
                                    [[IMGLYFont alloc] initWithDisplayName:@" " fontName:@"BodoniSvtyTwoITCTT-Book"],
                                    [[IMGLYFont alloc] initWithDisplayName:@" " fontName:@"BradleyHandITCTT-Bold"],
                                    [[IMGLYFont alloc] initWithDisplayName:@" " fontName:@"ChalkboardSE-Regular"],
                                    [[IMGLYFont alloc] initWithDisplayName:@" " fontName:@"DINAlternate-Bold"],
                                    [[IMGLYFont alloc] initWithDisplayName:@" " fontName:@"HelveticaNeue"],
                                    [[IMGLYFont alloc] initWithDisplayName:@" " fontName:@"Noteworthy-Bold"],
                                    [[IMGLYFont alloc] initWithDisplayName:@" " fontName:@"SnellRoundhand"],
                                    [[IMGLYFont alloc] initWithDisplayName:@" " fontName:@"Thonburi"]
                                    ];

    return fonts;
}

- (IMGLYConfiguration *)imglyConfigurationWithEmbellishmentManager:(PGEmbellishmentMetricsManager *)embellishmentMetricsManager
{
    self.titleBlock = ^(UIView * _Nonnull view) {
        if ([view isKindOfClass:[UILabel class]]) {
            ((UILabel *)view).text = nil;
        }
    };

    self.colorBlock = ^(IMGLYColorCollectionViewCell * _Nonnull cell, UIColor * _Nonnull color, NSString * _Nonnull colorName) {
        CGRect cellFrame = cell.frame;
        cellFrame.size.height = cellFrame.size.width;
        cell.frame = cellFrame;
        cell.colorView.layer.cornerRadius = cellFrame.size.width / 2.0;
        cell.colorView.layer.masksToBounds = YES;

        NSArray<NSLayoutConstraint *> *constraints = cell.imageView.superview.constraints;

        [NSLayoutConstraint deactivateConstraints:@[[constraints lastObject]]];

        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:cell.imageView
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:cell.imageView.superview
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0.0];

        centerY.priority = UILayoutPriorityRequired;

        [cell.imageView.superview addConstraint:centerY];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
    };

    IMGLYPhotoEffect.allEffects = [self photoEffects];

    IMGLYFontImporter.fonts = [self fonts];

    PESDK.bundleImageBlock = ^UIImage * _Nullable(NSString * _Nonnull imageName) {
        if ([imageName isEqualToString:@"save_image_icon"]) {
            imageName = @"ic_approve_44pt";
        }

        // Getting the images from our own bundle if there is a replacement
        return [UIImage imageNamed:imageName];
    };


    IMGLYConfiguration *configuration = [[IMGLYConfiguration alloc] initWithBuilder:^(IMGLYConfigurationBuilder * _Nonnull builder) {

        builder.accessoryViewBackgroundColor = [UIColor HPRowColor];


        // Editor general configuration

        [builder configurePhotoEditorViewController:^(IMGLYPhotoEditViewControllerOptionsBuilder * _Nonnull photoEditorBuilder) {

            photoEditorBuilder.frameScaleMode = UIViewContentModeScaleToFill;
            photoEditorBuilder.backgroundColor = [UIColor HPRowColor];
            photoEditorBuilder.allowsPreviewImageZoom = NO;

            photoEditorBuilder.titleViewConfigurationClosure = self.titleBlock;

            photoEditorBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"editor-tool-apply-btn";
            };

            PGEmbellishmentMetric *autofixMetric = [[PGEmbellishmentMetric alloc] initWithName:@"Auto-fix" andCategoryType:PGEmbellishmentCategoryTypeEdit];

            photoEditorBuilder.actionButtonConfigurationBlock = ^(IMGLYIconCaptionCollectionViewCell * _Nonnull cell, IMGLYBoxedMenuItem * _Nonnull item) {
                cell.tintColor = [UIColor HPGrayBackgroundColor];
                cell.imageView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
                cell.imageView.highlightedImage = nil;
                cell.captionLabel.text = nil;
                cell.imageView.highlighted = NO;

                if ([item.title isEqualToString:kImglyMenuItemMagic]) {
                    cell.imageView.highlightedImage = [UIImage imageNamed:@"ic_magic_active_48pt"];
                    cell.imageView.image = [UIImage imageNamed:@"ic_magic_48pt"];
                    cell.accessibilityIdentifier = @"editMagic";

                    if ([embellishmentMetricsManager hasEmbellishmentMetric:autofixMetric]) {
                        cell.imageView.highlighted = YES;
                    }

                } else if ([item.title isEqualToString:kImglyMenuItemFilter]) {
                    cell.accessibilityIdentifier = @"editFilters";

                } else if ([item.title isEqualToString:kImglyMenuItemFrame]) {
                    cell.accessibilityIdentifier = @"editFrame";

                } else if ([item.title isEqualToString:kImglyMenuItemSticker]) {
                    cell.accessibilityIdentifier = @"editSticker";

                } else if ([item.title isEqualToString:kImglyMenuItemText]) {
                    cell.accessibilityIdentifier = @"editText";

                } else if ([item.title isEqualToString:kImglyMenuItemCrop]) {
                    cell.accessibilityIdentifier = @"editCrop";
                }
            };

            photoEditorBuilder.photoEditorActionSelectedBlock = ^(IMGLYBoxedMenuItem * _Nonnull item) {
                if ([item.title isEqualToString:kImglyMenuItemMagic]) {
                    if ([embellishmentMetricsManager hasEmbellishmentMetric:autofixMetric]) {
                        [embellishmentMetricsManager removeEmbellishmentMetric:autofixMetric];
                    } else {
                        [embellishmentMetricsManager addEmbellishmentMetric:autofixMetric];
                    }
                }
            };

        }];


        // Filters configuration

        [builder configureFilterToolController:^(IMGLYFilterToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"filter-tool-apply-btn";
            };

            toolBuilder.filterCellConfigurationClosure = ^(IMGLYFilterCollectionViewCell * _Nonnull cell, IMGLYPhotoEffect * _Nonnull effect) {
                cell.captionLabel.text = nil;
                [cell.selectionLabel removeFromSuperview];

                cell.selectionIndicator.backgroundColor = [UIColor HPBlueColor];
            };

            toolBuilder.filterSelectedClosure = ^(IMGLYPhotoEffect * _Nonnull filter) {
                [embellishmentMetricsManager clearEmbellishmentMetricForCategory:PGEmbellishmentCategoryTypeFilter];
                [embellishmentMetricsManager addEmbellishmentMetric:[[PGEmbellishmentMetric alloc] initWithName:filter.displayName andCategoryType:PGEmbellishmentCategoryTypeFilter]];
            };

            toolBuilder.filterIntensitySliderConfigurationClosure = ^(IMGLYSlider * _Nonnull slider) {
                slider.filledTrackColor = [UIColor HPBlueColor];
                slider.thumbTintColor = [UIColor HPBlueColor];
            };
        }];


        // Frames configuration

        [builder configureFrameToolController:^(IMGLYFrameToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"frame-tool-apply-btn";
            };

            toolBuilder.frameDataSourceConfigurationClosure = ^(IMGLYFrameDataSource * _Nonnull dataSource) {
                dataSource.allFrames = [[PGFrameManager sharedInstance] imglyFrames];
            };

            toolBuilder.frameCellConfigurationClosure = ^(IMGLYIconBorderedCollectionViewCell * _Nonnull cell, IMGLYFrame * _Nonnull frame) {
                cell.tintColor = [UIColor HPRowColor];
                cell.borderColor = [UIColor HPRowColor];
                cell.contentView.backgroundColor = [UIColor HPRowColor];

                [NSLayoutConstraint deactivateConstraints:cell.imageView.constraints];
                [cell.imageView addConstraints:[self thumbnailSizeConstraintsFor:cell.imageView width:60.0 height:60.0]];
                [cell.imageView setNeedsUpdateConstraints];
                [cell.imageView updateConstraintsIfNeeded];
            };

            toolBuilder.noFrameCellConfigurationClosure = ^(IMGLYIconCaptionCollectionViewCell * _Nonnull cell) {
                cell.captionLabel.text = nil;

                [NSLayoutConstraint deactivateConstraints:cell.imageView.constraints];
                [cell.imageView addConstraints:[self thumbnailSizeConstraintsFor:cell.imageView width:50.0 height:50.0]];
                [cell.imageView setNeedsUpdateConstraints];
                [cell.imageView updateConstraintsIfNeeded];
            };

            toolBuilder.selectedFrameClosure = ^(IMGLYFrame * _Nullable frame) {
                NSString *frameName = @"NoFrame";

                if (frame) {
                    frameName = frame.accessibilityLabel;
                }

                [embellishmentMetricsManager clearEmbellishmentMetricForCategory:PGEmbellishmentCategoryTypeFrame];
                [embellishmentMetricsManager addEmbellishmentMetric:[[PGEmbellishmentMetric alloc] initWithName:frameName andCategoryType:PGEmbellishmentCategoryTypeFrame]];
            };
        }];


        // Stickers configuration

        [builder configureStickerToolController:^(IMGLYStickerToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"sticker-tool-apply-btn";
            };

            toolBuilder.stickerCategoryDataSourceConfigurationClosure = ^(IMGLYStickerCategoryDataSource * _Nonnull dataSource) {
                NSArray<IMGLYSticker *> *allStickers = [[PGStickerManager sharedInstance] imglyStickers];
                NSURL *thumbnailURL = [[NSBundle mainBundle] URLForResource:@"imglyStickerCategory" withExtension:@"png"];
                IMGLYStickerCategory *category = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                    imageURL:thumbnailURL
                                                                                    stickers:allStickers];

                dataSource.stickerCategories = @[category];
            };

            toolBuilder.stickerCategoryButtonConfigurationClosure = ^(IMGLYIconBorderedCollectionViewCell * _Nonnull cell, IMGLYStickerCategory * _Nonnull category) {
                cell.tintColor = [UIColor HPBlueColor];
                cell.borderColor = [UIColor HPRowColor];
                cell.contentView.backgroundColor = [UIColor HPRowColor];
            };

            toolBuilder.addedStickerClosure = ^(IMGLYSticker * _Nonnull sticker) {
                PGEmbellishmentMetric *stickerMetric = [[PGEmbellishmentMetric alloc] initWithName:sticker.accessibilityLabel andCategoryType:PGEmbellishmentCategoryTypeSticker];
                [embellishmentMetricsManager addEmbellishmentMetric:stickerMetric];
            };

        }];

        [builder configureStickerColorToolController:^(IMGLYStickerColorToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.colorActionButtonConfigurationClosure = self.colorBlock;

            toolBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"sticker-color-tool-apply-btn";
            };
        }];

        [builder configureStickerOptionsToolController:^(IMGLYStickerOptionsToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"sticker-options-tool-apply-btn";
            };

            toolBuilder.actionButtonConfigurationClosure = ^(UICollectionViewCell * _Nonnull cell, enum StickerAction action) {
                if ([cell isKindOfClass:[IMGLYIconCaptionCollectionViewCell class]]) {
                    IMGLYIconCaptionCollectionViewCell *itemCell = (IMGLYIconCaptionCollectionViewCell *) cell;

                    itemCell.captionLabel.text = nil;
                }
            };
        }];


        // Text configuration

        [builder configureTextToolController:^(IMGLYTextToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"text-tool-apply-btn";
            };

            toolBuilder.textViewConfigurationClosure = ^(UITextView * _Nonnull textView) {
                static NSInteger numTextFields = 0;

                [textView setKeyboardAppearance:UIKeyboardAppearanceDark];
                [textView setAccessibilityIdentifier:[NSString stringWithFormat:@"txtField%ld", (long)numTextFields]];
            };
        }];

        [builder configureTextFontToolController:^(IMGLYTextFontToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"text-font-tool-apply-btn";
            };

            toolBuilder.actionButtonConfigurationClosure = ^(IMGLYLabelCaptionCollectionViewCell * _Nonnull cell, NSString * _Nonnull action) {
                cell.captionLabel.text = nil;
                cell.label.highlightedTextColor = [UIColor HPBlueColor];

                UIFont *font = [UIFont fontWithName:cell.label.font.familyName size:28.0];
                cell.label.font = font;
            };

        }];

        [builder configureTextColorToolController:^(IMGLYTextColorToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.textColorActionButtonConfigurationClosure = self.colorBlock;

            toolBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"text-color-tool-apply-btn";
            };
        }];

        [builder configureTextOptionsToolController:^(IMGLYTextOptionsToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"text-options-tool-apply-btn";
            };

            toolBuilder.actionButtonConfigurationClosure = ^(UICollectionViewCell * _Nonnull cell, enum TextAction action) {
                UIImage *image;

                if ([cell isKindOfClass:[IMGLYIconCaptionCollectionViewCell class]]) {
                    IMGLYIconCaptionCollectionViewCell *itemCell = (IMGLYIconCaptionCollectionViewCell *) cell;

                    itemCell.captionLabel.text = nil;

                    if (image) {
                        itemCell.imageView.image = image;
                    }

                } else if ([cell isKindOfClass:[IMGLYLabelCaptionCollectionViewCell class]]) {
                    IMGLYLabelCaptionCollectionViewCell *itemCell = (IMGLYLabelCaptionCollectionViewCell *) cell;

                    UIFont *font = [UIFont fontWithName:itemCell.label.font.familyName size:32.0];
                    itemCell.label.font = font;
                    itemCell.captionLabel.text = nil;
                }
            };
        }];


        // Transform/Crop configuration

        [builder configureTransformToolController:^(IMGLYTransformToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                button.accessibilityLabel = @"transform-tool-apply-btn";
            };

            toolBuilder.allowFreeCrop = NO;

            IMGLYCropAspect *cropAspect2x3 = [[IMGLYCropAspect alloc] initWithWidth:2.0 height:3.0 localizedName:@"2:3" rotatable:NO];
            cropAspect2x3.accessibilityLabel = @"2:3 crop ratio";
            IMGLYCropAspect *cropAspect3x2 = [[IMGLYCropAspect alloc] initWithWidth:3.0 height:2.0 localizedName:@"3:2" rotatable:NO];
            cropAspect3x2.accessibilityLabel = @"3:2 crop ratio";

            toolBuilder.allowedCropRatios = @[cropAspect2x3, cropAspect3x2];

            toolBuilder.cropAspectButtonConfigurationClosure = ^(IMGLYLabelBorderedCollectionViewCell * _Nonnull cell, IMGLYCropAspect * _Nullable cropAspect) {
                cell.tintColor = [UIColor HPBlueColor];
                cell.borderColor = [UIColor HPRowColor];
                cell.contentView.backgroundColor = [UIColor HPRowColor];
                cell.textLabel.highlightedTextColor = [UIColor HPBlueColor];
            };
        }];

    }];

    return configuration;
}

- (NSArray<NSLayoutConstraint *> *)thumbnailSizeConstraintsFor:(UIImageView *)imageView width:(CGFloat)width height:(CGFloat)height {
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:imageView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:width];

    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:imageView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:height];

    return @[widthConstraint, heightConstraint];
}

- (IMGLYPhotoEffect *)imglyFilterByName:(NSString *)name {
    NSBundle *photoEffectBundle = [NSBundle bundleForClass:[IMGLYPhotoEffect class]];
    NSURL *effectUrl = [photoEffectBundle URLForResource:name withExtension:@"png" subdirectory:@"imglyKit.bundle"];

    return [[IMGLYPhotoEffect alloc] initWithIdentifier:name lutURL:effectUrl displayName:name];
}

@end
