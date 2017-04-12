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
                                                                         icon:[[UIImage imageNamed:@"auto_enhance_Off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                       action:^IMGLYBoxedPhotoEditModel * _Nonnull(IMGLYBoxedPhotoEditModel * _Nonnull photoEditModel) {
                                                                           photoEditModel.isAutoEnhancementEnabled = !photoEditModel.isAutoEnhancementEnabled;
                                                                           return photoEditModel;
                                                                       }
                                                                        state:nil];

    IMGLYBoxedMenuItem *filterItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemFilter
                                                                          icon:[UIImage imageNamed:@"editFilters"]
                                                                          tool:[[IMGLYFilterToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *frameItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemFrame
                                                                         icon:[UIImage imageNamed:@"editFrame"]
                                                                         tool:[[IMGLYFrameToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *stickerItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemSticker
                                                                           icon:[UIImage imageNamed:@"editSticker"]
                                                                           tool:[[IMGLYStickerToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *textItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemText
                                                                        icon:[UIImage imageNamed:@"editText"]
                                                                        tool:[[IMGLYTextToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *cropItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemCrop
                                                                        icon:[UIImage imageNamed:@"editCrop"]
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

- (IMGLYConfiguration *)imglyConfigurationWithEmbellishmentManager:(PGEmbellishmentMetricsManager *)embellishmentMetricsManager
{
    self.titleBlock = ^(UIView * _Nonnull view) {
        if ([view isKindOfClass:[UILabel class]]) {
            ((UILabel *)view).text = nil;
        }
    };

    IMGLYPhotoEffect.allEffects = [self photoEffects];

    PESDK.bundleImageBlock = ^UIImage * _Nullable(NSString * _Nonnull imageName) {
        UIImage *image;

        if ([imageName isEqualToString:@"ic_cancel_44pt"]) {
            image = [UIImage imageNamed:@"ic_cancel_44pt" inBundle:[NSBundle imglyKitBundle] compatibleWithTraitCollection:nil];

        } else if ([imageName isEqualToString:@"save_image_icon"]) {
            image = [UIImage imageNamed:@"ic_approve_44pt" inBundle:[NSBundle imglyKitBundle] compatibleWithTraitCollection:nil];

        } else if ([imageName isEqualToString:@"ic_approve_44pt"]) {
            image = [UIImage imageNamed:@"ic_approve_44pt" inBundle:[NSBundle imglyKitBundle] compatibleWithTraitCollection:nil];
        }

        image = [image imageWithTint:[UIColor whiteColor]];

        return image;
    };


    IMGLYConfiguration *configuration = [[IMGLYConfiguration alloc] initWithBuilder:^(IMGLYConfigurationBuilder * _Nonnull builder) {

        builder.accessoryViewBackgroundColor = [UIColor HPRowColor];


        // Editor general configuration

        [builder configurePhotoEditorViewController:^(IMGLYPhotoEditViewControllerOptionsBuilder * _Nonnull photoEditorBuilder) {

            photoEditorBuilder.allowedPhotoEditOverlayActionsAsNSNumbers = @[];

            photoEditorBuilder.frameScaleMode = UIViewContentModeScaleToFill;
            photoEditorBuilder.backgroundColor = [UIColor HPRowColor];
            photoEditorBuilder.allowsPreviewImageZoom = NO;

            photoEditorBuilder.titleViewConfigurationClosure = self.titleBlock;

            photoEditorBuilder.applyButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button) {
                // Workaround to fix saving image bug on slower devices.
                button.enabled = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    button.enabled = YES;
                });
            };

            PGEmbellishmentMetric *autofixMetric = [[PGEmbellishmentMetric alloc] initWithName:@"Auto-fix" andCategoryType:PGEmbellishmentCategoryTypeEdit];

            photoEditorBuilder.actionButtonConfigurationBlock = ^(IMGLYIconCaptionCollectionViewCell * _Nonnull cell, IMGLYBoxedMenuItem * _Nonnull item) {
                cell.tintColor = [UIColor HPGrayBackgroundColor];
                cell.imageView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
                cell.imageView.highlightedImage = nil;
                cell.captionLabel.text = nil;

                if ([item.title isEqualToString:kImglyMenuItemMagic]) {
                    cell.imageView.highlightedImage = [[UIImage imageNamed:@"auto_enhance_On"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    cell.imageView.image = [[UIImage imageNamed:@"auto_enhance_Off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    cell.accessibilityIdentifier = @"editMagic";

                    if ([embellishmentMetricsManager hasEmbellishmentMetric:autofixMetric]) {
                        cell.imageView.highlighted = YES;
                    } else {
                        cell.imageView.highlighted = NO;
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

            toolBuilder.frameDataSourceConfigurationClosure = ^(IMGLYFrameDataSource * _Nonnull dataSource) {
                dataSource.allFrames = [[PGFrameManager sharedInstance] imglyFrames];
            };

            toolBuilder.frameCellConfigurationClosure = ^(IMGLYIconBorderedCollectionViewCell * _Nonnull cell, IMGLYFrame * _Nonnull frame) {
                cell.tintColor = [UIColor HPBlueColor];
                cell.borderColor = [UIColor HPRowColor];
            };

            toolBuilder.noFrameCellConfigurationClosure = ^(IMGLYIconCaptionCollectionViewCell * _Nonnull cell) {
                cell.tintColor = [UIColor HPBlueColor];
                cell.captionLabel.highlightedTextColor = [UIColor HPBlueColor];
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

            toolBuilder.stickerCategoryDataSourceConfigurationClosure = ^(IMGLYStickerCategoryDataSource * _Nonnull dataSource) {
                NSArray<IMGLYSticker *> *allStickers = [[PGStickerManager sharedInstance] imglyStickers];
                IMGLYStickerCategory *category = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                    imageURL:[allStickers firstObject].thumbnailURL
                                                                                    stickers:allStickers];

                dataSource.stickerCategories = @[category];
            };

            toolBuilder.stickerCategoryButtonConfigurationClosure = ^(IMGLYIconBorderedCollectionViewCell * _Nonnull cell, IMGLYStickerCategory * _Nonnull category) {
                cell.tintColor = [UIColor HPBlueColor];
                cell.borderColor = [UIColor HPRowColor];
            };

            toolBuilder.addedStickerClosure = ^(IMGLYSticker * _Nonnull sticker) {
                PGEmbellishmentMetric *stickerMetric = [[PGEmbellishmentMetric alloc] initWithName:sticker.accessibilityLabel andCategoryType:PGEmbellishmentCategoryTypeSticker];
                [embellishmentMetricsManager addEmbellishmentMetric:stickerMetric];
            };

        }];

        [builder configureStickerOptionsToolController:^(IMGLYStickerOptionsToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

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

            toolBuilder.textViewConfigurationClosure = ^(UITextView * _Nonnull textView) {
                static NSInteger numTextFields = 0;

                [textView setKeyboardAppearance:UIKeyboardAppearanceDark];
                [textView setAccessibilityIdentifier:[NSString stringWithFormat:@"txtField%ld", (long)numTextFields]];
            };
        }];

        [builder configureTextFontToolController:^(IMGLYTextFontToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.actionButtonConfigurationClosure = ^(IMGLYLabelCaptionCollectionViewCell * _Nonnull cell, NSString * _Nonnull action) {
                cell.captionLabel.text = nil;
                cell.label.highlightedTextColor = [UIColor HPBlueColor];

                UIFont *font = [UIFont fontWithName:cell.label.font.familyName size:28.0];
                cell.label.font = font;
            };

        }];

        [builder configureTextColorToolController:^(IMGLYTextColorToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.textColorActionButtonConfigurationClosure = ^(IMGLYColorCollectionViewCell * _Nonnull cell, UIColor * _Nonnull color, NSString * _Nonnull colorName) {
                CGRect cellRect = cell.frame;
                cellRect.size.height = cellRect.size.width;
                cell.frame = cellRect;
                cell.colorView.layer.cornerRadius = cellRect.size.width / 2;
                cell.colorView.layer.masksToBounds = YES;

//                cell.imageView.image = nil; // to be replaced by final image
            };
        }];

        [builder configureTextOptionsToolController:^(IMGLYTextOptionsToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.actionButtonConfigurationClosure = ^(UICollectionViewCell * _Nonnull cell, enum TextAction action) {
                UIImage *image;

                switch (action) {
                    case TextActionSelectFont:
                        image = [UIImage imageNamed:@"imglyIconFont"];
                        break;

                    case TextActionSelectColor:
                        image = [UIImage imageNamed:@"imglyIconColor"];
                        break;

                    case TextActionSelectBackgroundColor:
                        image = [UIImage imageNamed:@"imglyIconBackgroundColor"];
                        break;
                        
                    default:
                        break;
                };

                if ([cell isKindOfClass:[IMGLYIconCaptionCollectionViewCell class]]) {
                    IMGLYIconCaptionCollectionViewCell *itemCell = (IMGLYIconCaptionCollectionViewCell *) cell;

                    itemCell.captionLabel.text = nil;

                    if (image) {
                        itemCell.imageView.image = image;
                    }

                } else if ([cell isKindOfClass:[IMGLYLabelCaptionCollectionViewCell class]]) {
                    IMGLYLabelCaptionCollectionViewCell *itemCell = (IMGLYLabelCaptionCollectionViewCell *) cell;

                    itemCell.label.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightUltraLight];
                    itemCell.captionLabel.text = nil;
                }
            };
        }];


        // Transform/Crop configuration

        [builder configureTransformToolController:^(IMGLYTransformToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = self.titleBlock;

            toolBuilder.allowFreeCrop = NO;

            IMGLYCropAspect *cropAspect2x3 = [[IMGLYCropAspect alloc] initWithWidth:2.0 height:3.0 localizedName:@"2:3" rotatable:NO];
            cropAspect2x3.accessibilityLabel = @"2:3 crop ratio";
            IMGLYCropAspect *cropAspect3x2 = [[IMGLYCropAspect alloc] initWithWidth:3.0 height:2.0 localizedName:@"3:2" rotatable:NO];
            cropAspect3x2.accessibilityLabel = @"3:2 crop ratio";

            toolBuilder.allowedCropRatios = @[cropAspect2x3, cropAspect3x2];

            toolBuilder.transformButtonConfigurationClosure = ^(IMGLYButton * _Nonnull button, enum TransformAction action) {
                // workaround because toolBuilder.allowedTransformActionsAsNSNumbers = @[]; does not seem to work yet as of 6.5.3. maybe in a future version...
                [button.superview setHidden:YES];
            };

            toolBuilder.cropAspectButtonConfigurationClosure = ^(IMGLYLabelBorderedCollectionViewCell * _Nonnull cell, IMGLYCropAspect * _Nullable cropAspect) {
                cell.tintColor = [UIColor HPBlueColor];
                cell.borderColor = [UIColor HPRowColor];
                cell.textLabel.highlightedTextColor = [UIColor HPBlueColor];
            };
        }];

    }];

    return configuration;
}

- (IMGLYPhotoEffect *)imglyFilterByName:(NSString *)name {
    NSBundle *photoEffectBundle = [NSBundle bundleForClass:[IMGLYPhotoEffect class]];
    NSURL *effectUrl = [photoEffectBundle URLForResource:name withExtension:@"png" subdirectory:@"imglyKit.bundle"];

    return [[IMGLYPhotoEffect alloc] initWithIdentifier:name lutURL:effectUrl displayName:name];
}

@end
