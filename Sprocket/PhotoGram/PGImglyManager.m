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
#import "PGCustomStickerManager.h"
#import <imglyKit/IMGLYAnalyticsConstants.h>

static NSString * const kImglyMenuItemMagic = @"Magic";
static NSString * const kImglyMenuItemAdjust = @"Adjust";
static NSString * const kImglyMenuItemFilter = @"Filter";
static NSString * const kImglyMenuItemFrame = @"Frame";
static NSString * const kImglyMenuItemSticker = @"Sticker";
static NSString * const kImglyMenuItemBrush = @"Brush";
static NSString * const kImglyMenuItemText = @"Text";
static NSString * const kImglyMenuItemCrop = @"Crop";

NSString * const kPGImglyManagerCustomStickerPrefix = @"CS";
NSString * const kPGImglyManagerStickersChangedNotification = @"kPGImglyManagerStickersChangedNotification";

@interface PGImglyManager() <IMGLYAnalyticsClient>

@property (nonatomic, strong) NSDictionary *menuItems;
@property (nonatomic, strong) IMGLYAnalyticsScreenViewName currentScreenName;
@property (nonatomic, strong) IMGLYSticker *selectedSticker;
@property (nonatomic, strong) NSString *selectedFilter;
@property (nonatomic, strong) NSString *selectedFrame;
@property (nonatomic, strong) PGEmbellishmentMetricsManager *embellishmentMetricsManager;

@property (nonatomic, copy) void (^colorBlock)(IMGLYColorCollectionViewCell * _Nonnull cell, UIColor * _Nonnull color, NSString * _Nonnull colorName);
@property (strong, nonatomic) IMGLYStickerCategoryDataSource *stickerCategoryDataSource;

@property (strong, nonatomic) NSArray <NSString *> *adjustNames;

@end

@implementation PGImglyManager

int const kCustomButtonTag = 9999;

- (instancetype)init {
    self = [super init];

    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURL *licenseURL = [[NSBundle mainBundle] URLForResource:@"imgly_license" withExtension:@""];
            [PESDK unlockWithLicenseAt:licenseURL];
        });
        
        self.adjustNames = @[@"Brightness", @"Contrast", @"Saturation", @"Highlights", @"Exposure", @"Clarity"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStickerChangedNotification:) name:kPGImglyManagerStickersChangedNotification object:nil];
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

    IMGLYBoxedMenuItem *adjustItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemAdjust
                                                                          icon:[UIImage imageNamed:@"ic_adjust_48pt"]
                                                                          tool:[[IMGLYAdjustToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *filterItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemFilter
                                                                          icon:[UIImage imageNamed:@"ic_filter_48pt"]
                                                                          tool:[[IMGLYFilterToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *frameItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemFrame
                                                                         icon:[UIImage imageNamed:@"ic_frame_48pt"]
                                                                         tool:[[IMGLYFrameToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *stickerItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemSticker
                                                                           icon:[UIImage imageNamed:@"ic_sticker_48pt"]
                                                                           tool:[[IMGLYStickerToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *brushItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemBrush
                                                                        icon:[UIImage imageNamed:@"ic_brush_48pt"]
                                                                        tool:[[IMGLYBrushToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *textItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemText
                                                                        icon:[UIImage imageNamed:@"ic_text_48pt"]
                                                                        tool:[[IMGLYTextToolController alloc] initWithConfiguration:configuration]];

    IMGLYBoxedMenuItem *cropItem = [[IMGLYBoxedMenuItem alloc] initWithTitle:kImglyMenuItemCrop
                                                                        icon:[UIImage imageNamed:@"ic_crop_48pt"]
                                                                        tool:[[IMGLYTransformToolController alloc] initWithConfiguration:configuration]];

    return @[
             magicItem,
             adjustItem,
             filterItem,
             frameItem,
             stickerItem,
             brushItem,
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
    self.embellishmentMetricsManager = embellishmentMetricsManager;
    self.colorBlock = ^(IMGLYColorCollectionViewCell * _Nonnull cell, UIColor * _Nonnull color, NSString * _Nonnull colorName) {
        CGRect cellFrame = cell.frame;
        cellFrame.size.height = cellFrame.size.width;
        cell.frame = cellFrame;
        cell.colorView.layer.cornerRadius = cellFrame.size.width / 2.0;
        cell.colorView.layer.masksToBounds = YES;

        cell.accessibilityLabel = colorName;

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
            photoEditorBuilder.allowedPhotoEditOverlayActionsAsNSNumbers = @[];
            photoEditorBuilder.frameScaleMode = UIViewContentModeScaleToFill;
            photoEditorBuilder.backgroundColor = [UIColor HPRowColor];
            photoEditorBuilder.allowsPreviewImageZoom = NO;

            photoEditorBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"editor-tool-screen"];

            photoEditorBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"editor-tool-apply-btn"];
            
            photoEditorBuilder.discardConfirmationClosure = ^(IMGLYPhotoEditViewController * _Nonnull photoEditViewController, void (^ _Nonnull closure)(void)) {
                [embellishmentMetricsManager clearAllEmbellishmentMetrics];
                [photoEditViewController dismissViewControllerAnimated:YES completion:nil];
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

                } else if ([item.title isEqualToString:kImglyMenuItemAdjust]) {
                    cell.accessibilityIdentifier = @"editAdjust";
                    
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

        // Adjust configuration
        
        [builder configureAdjustToolController:^(IMGLYAdjustToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"adjust-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"adjust-tool-apply-btn"];
            
            toolBuilder.allowedAdjustToolsAsNSNumbers = @[[NSNumber numberWithInteger:AdjustToolBrightness],
                                                          [NSNumber numberWithInteger:AdjustToolContrast],
                                                          [NSNumber numberWithInteger:AdjustToolSaturation]];

            toolBuilder.sliderConfigurationClosure = ^(IMGLYSlider * _Nonnull slider) {
                slider.filledTrackColor = [UIColor HPBlueColor];
                slider.thumbTintColor = [UIColor HPBlueColor];
            };
            
            toolBuilder.adjustToolButtonConfigurationClosure = ^(IMGLYIconCaptionCollectionViewCell * _Nonnull cell, enum AdjustTool tool) {
                cell.captionLabel.text = nil;
            };
            
            toolBuilder.sliderChangedValueClosure = ^(IMGLYSlider * _Nonnull slider, enum AdjustTool tool) {
                if (tool < self.adjustNames.count) {
                    NSString *name = self.adjustNames[tool];
                    
                    PGEmbellishmentMetric *adjustMetric = [[PGEmbellishmentMetric alloc] initWithName:name andCategoryType:PGEmbellishmentCategoryTypeEdit];
                    
                    if (![embellishmentMetricsManager hasEmbellishmentMetric:adjustMetric]) {
                        [embellishmentMetricsManager addEmbellishmentMetric:adjustMetric];
                    }
                }
            };
        }];

        // Filters configuration

        [builder configureFilterToolController:^(IMGLYFilterToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"filter-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"filter-tool-apply-btn"];


            toolBuilder.filterCellConfigurationClosure = ^(IMGLYFilterCollectionViewCell * _Nonnull cell, IMGLYPhotoEffect * _Nonnull effect) {
                cell.captionLabel.text = nil;
                [cell.selectionLabel removeFromSuperview];

                cell.selectionIndicator.backgroundColor = [UIColor HPBlueColor];
            };

            toolBuilder.filterIntensitySliderConfigurationClosure = ^(IMGLYSlider * _Nonnull slider) {
                slider.filledTrackColor = [UIColor HPBlueColor];
                slider.thumbTintColor = [UIColor HPBlueColor];
            };
        }];


        // Frames configuration

        [builder configureFrameToolController:^(IMGLYFrameToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"frame-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"frame-tool-apply-btn"];

            toolBuilder.frameDataSourceConfigurationClosure = ^(IMGLYFrameDataSource * _Nonnull dataSource) {
                dataSource.allFrames = [[PGFrameManager sharedInstance] imglyFrames];
            };

            toolBuilder.frameCellConfigurationClosure = ^(IMGLYIconBorderedCollectionViewCell * _Nonnull cell, IMGLYFrame * _Nonnull frame) {
                cell.tintColor = [UIColor HPRowColor];
                cell.borderColor = [UIColor HPRowColor];
                cell.contentView.backgroundColor = [UIColor HPRowColor];

                cell.accessibilityLabel = frame.accessibilityLabel;

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
        }];


        // Stickers configuration

        [builder configureStickerToolController:^(IMGLYStickerToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"sticker-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"sticker-tool-apply-btn"];

            toolBuilder.stickerCategoryDataSourceConfigurationClosure = ^(IMGLYStickerCategoryDataSource * _Nonnull dataSource) {
                self.stickerCategoryDataSource = dataSource;

                dataSource.stickerCategoriesChangedClosure = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSIndexPath *path = [NSIndexPath indexPathForItem:1 inSection:0];

                        UICollectionView *collectionView = self.stickerCategoryDataSource.collectionView;
                        [collectionView selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
                        [collectionView.delegate collectionView:collectionView didSelectItemAtIndexPath:path];
                    });
                };

                dataSource.stickerCategories = [PGStickerManager sharedInstance].IMGLYStickersCategories;
            };

            toolBuilder.stickerCategoryButtonConfigurationClosure = ^(IMGLYIconBorderedCollectionViewCell * _Nonnull cell, IMGLYStickerCategory * _Nonnull category) {
                cell.tintColor = [UIColor HPBlueColor];
                cell.borderColor = [UIColor HPRowColor];
                cell.contentView.backgroundColor = [UIColor HPRowColor];
                cell.accessibilityLabel = category.accessibilityLabel;
                [self resetCustomSticker:cell];
                if ([category.accessibilityLabel isEqualToString:@"Add Custom Sticker"]) {
                    cell.tintColor = [UIColor HPRowColor];
                    [self configureAddCustomStickerView:cell];
                }
                if ([category.accessibilityLabel isEqualToString:@"Custom Stickers"]) {
                    [self configureCustomStickerCategoryView:cell];
                }
            };

            toolBuilder.stickerButtonConfigurationClosure = ^(IMGLYIconCollectionViewCell * _Nonnull cell, IMGLYSticker * _Nonnull sticker) {
                cell.accessibilityLabel = sticker.accessibilityLabel;
                cell.accessibilityValue = sticker.accessibilityValue;
                [self resetCustomSticker:cell];

                NSError *error = NULL;
                NSString *pattern = [NSString stringWithFormat:@"^%@[0-9]{%d}$", kPGImglyManagerCustomStickerPrefix, kCustomStickerManagerPrefixLength];
                NSRegularExpression *regex = [NSRegularExpression
                                              regularExpressionWithPattern:pattern
                                              options:NSRegularExpressionCaseInsensitive
                                              error:&error];

                if (sticker.accessibilityLabel) {
                    [regex enumerateMatchesInString:sticker.accessibilityLabel
                                            options:0
                                              range:NSMakeRange(0, [sticker.accessibilityLabel length])
                                         usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                        [self configureCustomStickerView:cell];
                    }];
                }
            };

            toolBuilder.addedStickerClosure = ^(IMGLYSticker * _Nonnull sticker) {
                PGEmbellishmentMetric *stickerMetric = [[PGEmbellishmentMetric alloc] initWithName:sticker.accessibilityLabel andCategoryType:PGEmbellishmentCategoryTypeSticker];
                [embellishmentMetricsManager addEmbellishmentMetric:stickerMetric];
            };
        }];

        [builder configureStickerColorToolController:^(IMGLYStickerColorToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"sticker-color-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"sticker-color-tool-apply-btn"];

            toolBuilder.colorActionButtonConfigurationClosure = self.colorBlock;

        }];

        [builder configureStickerOptionsToolController:^(IMGLYStickerOptionsToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.allowedStickerOverlayActionsAsNSNumbers = @[[NSNumber numberWithInteger:StickerOverlayActionAdd], [NSNumber numberWithInteger:StickerOverlayActionDelete]];
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"sticker-options-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"sticker-options-tool-apply-btn"];

            toolBuilder.actionButtonConfigurationClosure = ^(UICollectionViewCell * _Nonnull cell, enum StickerAction action) {
                if ([cell isKindOfClass:[IMGLYIconCaptionCollectionViewCell class]]) {
                    IMGLYIconCaptionCollectionViewCell *itemCell = (IMGLYIconCaptionCollectionViewCell *) cell;

                    itemCell.captionLabel.text = nil;
                }
            };
        }];


        // Text configuration

        [builder configureTextToolController:^(IMGLYTextToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"text-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"text-tool-apply-btn"];

            toolBuilder.textViewConfigurationClosure = ^(UITextView * _Nonnull textView) {
                static NSInteger numTextFields = 0;

                [textView setKeyboardAppearance:UIKeyboardAppearanceDark];
                [textView setAccessibilityIdentifier:[NSString stringWithFormat:@"txtField%ld", (long)numTextFields]];
            };
        }];

        [builder configureTextFontToolController:^(IMGLYTextFontToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"text-font-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"text-font-tool-apply-btn"];

            toolBuilder.actionButtonConfigurationClosure = ^(IMGLYLabelCaptionCollectionViewCell * _Nonnull cell, NSString * _Nonnull action) {
                cell.captionLabel.text = nil;
                cell.label.highlightedTextColor = [UIColor HPBlueColor];

                cell.accessibilityLabel = cell.label.font.familyName;

                UIFont *font = [UIFont fontWithName:cell.label.font.familyName size:28.0];
                cell.label.font = font;
            };

        }];

        [builder configureTextColorToolController:^(IMGLYTextColorToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"text-color-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"text-color-tool-apply-btn"];

            toolBuilder.textColorActionButtonConfigurationClosure = self.colorBlock;
        }];

        [builder configureTextOptionsToolController:^(IMGLYTextOptionsToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.allowedTextOverlayActionsAsNSNumbers = @[[NSNumber numberWithInteger:TextOverlayActionAdd], [NSNumber numberWithInteger:TextOverlayActionDelete]];
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"text-options-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"text-options-tool-apply-btn"];

            toolBuilder.actionButtonConfigurationClosure = ^(UICollectionViewCell * _Nonnull cell, enum TextAction action) {
                if ([cell isKindOfClass:[IMGLYIconCaptionCollectionViewCell class]]) {
                    IMGLYIconCaptionCollectionViewCell *itemCell = (IMGLYIconCaptionCollectionViewCell *) cell;

                    itemCell.captionLabel.text = nil;
                    
                } else if ([cell isKindOfClass:[IMGLYLabelCaptionCollectionViewCell class]]) {
                    IMGLYLabelCaptionCollectionViewCell *itemCell = (IMGLYLabelCaptionCollectionViewCell *) cell;

                    UIFont *font = [UIFont fontWithName:itemCell.label.font.familyName size:32.0];
                    itemCell.label.font = font;
                    itemCell.captionLabel.text = nil;
                }
            };
        }];


        // Brush configuration
        
        [builder configureBrushToolController:^(IMGLYBrushToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"brush-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"brush-tool-apply-btn"];
            
            toolBuilder.sliderConfigurationClosure = ^(IMGLYSlider * _Nonnull slider) {
                slider.filledTrackColor = [UIColor HPBlueColor];
                slider.thumbTintColor = [UIColor HPBlueColor];
            };
            
            toolBuilder.brushToolButtonConfigurationClosure = ^(UICollectionViewCell * _Nonnull cell, enum BrushTool tool) {
                IMGLYIconCaptionCollectionViewCell *itemCell = (IMGLYIconCaptionCollectionViewCell *) cell;
                
                itemCell.captionLabel.text = nil;
                
                if (BrushToolHardness == tool) {
                    itemCell.imageView.image = [UIImage imageNamed:@"imgly_icon_option_hardness"];
                    itemCell.imageView.highlightedImage = [UIImage imageNamed:@"imgly_icon_option_hardness_highlighted"];
                }
            };
            
            toolBuilder.allowedBrushOverlayActionsAsNSNumbers = @[[NSNumber numberWithInteger:BrushOverlayActionDelete]];
        }];
        
        [builder configureBrushColorToolController:^(IMGLYBrushColorToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"brush-color-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"brush-color-tool-apply-btn"];
            
            toolBuilder.brushColorActionButtonConfigurationClosure = self.colorBlock;
        }];

        
        // Transform/Crop configuration

        [builder configureTransformToolController:^(IMGLYTransformToolControllerOptionsBuilder * _Nonnull toolBuilder) {
            toolBuilder.titleViewConfigurationClosure = [self titleBlockWithAccessibilityLabel:@"transform-tool-screen"];
            toolBuilder.applyButtonConfigurationClosure = [self applyButtonBlockWithAccessibilityLabel:@"transform-tool-apply-btn"];

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
    
    [PESDK sharedInstance].analytics.isEnabled = YES;
    [[PESDK sharedInstance].analytics addAnalyticsClient:self];

    return configuration;
}

- (void)setPhotoEditViewController:(IMGLYPhotoEditViewController *)photoEditViewController
{
    _photoEditViewController = photoEditViewController;
    
    void (^ _Nullable selectionChangedHandler)(UIView * _Nullable, UIView * _Nullable) = photoEditViewController.overlayController.selectionChangedHandler;
    
    __weak PGImglyManager *weakSelf = self;
    photoEditViewController.overlayController.selectionChangedHandler = ^(UIView * _Nullable view1, UIView * _Nullable view2) {
        if (view2 && [view2 isKindOfClass:[IMGLYStickerImageView class]]) {
            weakSelf.selectedSticker = ((IMGLYStickerImageView *)view2).sticker;
        }
        selectionChangedHandler(view1, view2);
    };
    
    photoEditViewController.undoController.isEnabled = NO;
}

- (void (^)(IMGLYButton * _Nonnull))applyButtonBlockWithAccessibilityLabel:(NSString *)label {
    return ^(IMGLYButton * _Nonnull button) {
        button.accessibilityLabel = label;
    };
}

- (void (^)(UIView * _Nonnull))titleBlockWithAccessibilityLabel:(NSString *)label {
    return ^(UIView * _Nonnull view) {
        if ([view isKindOfClass:[UILabel class]]) {
            ((UILabel *)view).text = nil;
            view.accessibilityLabel = label;
        }
    };
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

#pragma mark - IMGLYAnalyticsClient

- (void)logScreenView:(IMGLYAnalyticsScreenViewName _Nonnull)screenView
{
    self.currentScreenName = screenView;
}

- (void)logEvent:(IMGLYAnalyticsEventName _Nonnull)event attributes:(NSDictionary<IMGLYAnalyticsEventAttributeName, id> * _Nullable)attributes
{
    if (event == IMGLYAnalyticsEventNameFilterSelect) {
        self.selectedFilter = attributes[IMGLYAnalyticsEventAttributeNameFilterType];
    }
    
    if (event == IMGLYAnalyticsEventNameFrameSelect) {
        if ([attributes[IMGLYAnalyticsEventAttributeNameFrame] isKindOfClass:[IMGLYFrame class]]) {
            self.selectedFrame = ((IMGLYFrame *)attributes[IMGLYAnalyticsEventAttributeNameFrame]).accessibilityLabel;
        }
    }
    
    if (event == IMGLYAnalyticsEventNameFrameDeselect) {
        self.selectedFrame = @"No Frame";
    }
    
    if (event == IMGLYAnalyticsEventNameApplyChanges) {
        if (self.currentScreenName == IMGLYAnalyticsScreenViewNameFilter) {
            [self.embellishmentMetricsManager clearEmbellishmentMetricForCategory:PGEmbellishmentCategoryTypeFilter];
            if (self.selectedFilter) {
                [self.embellishmentMetricsManager addEmbellishmentMetric:[[PGEmbellishmentMetric alloc] initWithName:self.selectedFilter andCategoryType:PGEmbellishmentCategoryTypeFilter]];
            }
        } else if (self.currentScreenName == IMGLYAnalyticsScreenViewNameFrame) {
            [self.embellishmentMetricsManager clearEmbellishmentMetricForCategory:PGEmbellishmentCategoryTypeFrame];
            if (self.selectedFrame) {
                [self.embellishmentMetricsManager addEmbellishmentMetric:[[PGEmbellishmentMetric alloc] initWithName:self.selectedFrame andCategoryType:PGEmbellishmentCategoryTypeFrame]];
            }
        }
    }
    
    if (event == IMGLYAnalyticsEventNameDiscardChanges) {
        if (self.currentScreenName == IMGLYAnalyticsScreenViewNameEditor) {
            [self.embellishmentMetricsManager clearAllEmbellishmentMetrics];
        } else if (self.currentScreenName == IMGLYAnalyticsScreenViewNameFilter) {
            self.selectedFilter = nil;
        } else if (self.currentScreenName == IMGLYAnalyticsScreenViewNameFrame) {
            self.selectedFrame = nil;
        } else if (self.currentScreenName == IMGLYAnalyticsScreenViewNameAdjust) {
            for (NSString *name in self.adjustNames) {
                PGEmbellishmentMetric *adjustMetric = [[PGEmbellishmentMetric alloc] initWithName:name andCategoryType:PGEmbellishmentCategoryTypeEdit];
                [self.embellishmentMetricsManager removeEmbellishmentMetric:adjustMetric];
            }
        }
    }
    
    if ((event == IMGLYAnalyticsEventNameStickerActionSelect) && (attributes[IMGLYAnalyticsEventAttributeNameAction] == IMGLYAnalyticsEventAttributeValueActionDelete)) {
        PGEmbellishmentMetric *stickerMetric = [[PGEmbellishmentMetric alloc] initWithName:self.selectedSticker.accessibilityLabel andCategoryType:PGEmbellishmentCategoryTypeSticker];
        
        [self.embellishmentMetricsManager removeEmbellishmentMetric:stickerMetric];
    }
}

#pragma mark - Custom Sticker

- (void)resetCustomSticker:(UICollectionViewCell *)cell
{
    UIView *customView = [cell.contentView viewWithTag:kCustomButtonTag];
    if (customView) {
        [customView removeFromSuperview];
    }
    
    if (cell.contentView.gestureRecognizers.count > 1) {
        [cell.contentView removeGestureRecognizer:cell.contentView.gestureRecognizers.lastObject];
    }
}

- (void)configureAddCustomStickerView:(UICollectionViewCell *)cell
{
    UIView *addButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height)];
    addButton.tag = kCustomButtonTag;
    addButton.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customAddTapped:)];
    [addButton addGestureRecognizer:recognizer];

    [cell.contentView addSubview:addButton];
}

- (void)configureCustomStickerCategoryView:(UICollectionViewCell *)cell
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(stickerCategoryLongTapped:)];
    [cell.contentView addGestureRecognizer:longPress];
}

- (void)configureCustomStickerView:(UICollectionViewCell *)cell
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(stickerLongTapped:)];
    [cell.contentView addGestureRecognizer:longPress];
}

- (void)stickerCategoryLongTapped:(UIGestureRecognizer *)recognizer
{
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        [[PGCustomStickerManager sharedInstance] deleteAllStickers:self.photoEditViewController];
    }
}

- (void)stickerLongTapped:(UIGestureRecognizer *)recognizer
{
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        UIView *stickerView = recognizer.view.superview;

        NSString *stickerId = [stickerView.accessibilityLabel stringByReplacingOccurrencesOfString:kPGImglyManagerCustomStickerPrefix withString:@""];
        NSString *unique = stickerView.accessibilityValue;
        NSString *filename = [NSString stringWithFormat:@"%@-%@", stickerId, unique];

        [[PGCustomStickerManager sharedInstance] deleteSticker:filename viewController:self.photoEditViewController];
    }
}

- (void)customAddTapped:(UIGestureRecognizer *)recognizer
{
    [[PGCustomStickerManager sharedInstance] presentCameraFromViewController:self.photoEditViewController];
}


#pragma mark - Notifications

- (void)handleStickerChangedNotification:(NSNotification *)notfication
{
    self.stickerCategoryDataSource.stickerCategories = [PGStickerManager sharedInstance].IMGLYStickersCategories;
}

@end
