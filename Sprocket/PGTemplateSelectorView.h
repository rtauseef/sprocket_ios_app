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

#import "PGView.h"
#import "PGTemplate.h"

@protocol PGTemplateSelectorViewDelegate;

@interface PGTemplateSelectorView : PGView

@property (strong, nonatomic) UIImage *selectedPhoto;
@property (strong, nonatomic) NSString *source;
@property (assign, nonatomic) NSInteger selectedTemplate;
@property (nonatomic, weak) id<PGTemplateSelectorViewDelegate> delegate;

- (void)selectTemplateWithName:(NSString *)name;

@end


@protocol PGTemplateSelectorViewDelegate <NSObject>

- (void)templateSelectorView:(PGTemplateSelectorView *)templateSelectorView didSelectTemplate:(PGTemplate *)template;
- (void)templateSelectorViewDidLongTap:(PGTemplateSelectorView *)templateSelectorView;

@end