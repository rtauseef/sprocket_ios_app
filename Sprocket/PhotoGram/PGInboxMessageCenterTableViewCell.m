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

#import "PGInboxMessageCenterTableViewCell.h"
#import "UIImageView+Cached.h"
#import "UIFont+Style.h"
#import "UIColor+Style.h"

@interface PGInboxMessageCenterTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UIImageView *unreadImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewImageHeightConstraint;

@end

@implementation PGInboxMessageCenterTableViewCell

- (void)setMessage:(UAInboxMessage *)message
{
    _message = message;

    [self setupView];
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.titleLabel.text = nil;
    self.subtitleLabel.text = nil;
    self.previewImage.image = nil;
}


#pragma mark - Private

- (void)setupView
{
    self.titleLabel.font = [UIFont HPSimplifiedLightFontWithSize:24.0];
    self.titleLabel.textColor = [UIColor HPRowColor];

    self.subtitleLabel.font = [UIFont HPSimplifiedRegularFontWithSize:16.0];
    self.subtitleLabel.textColor = [UIColor HPRowColor];

    NSString *messageID = self.message.messageID;
    NSString *previewImageURL = [self previewImageUrl];

    if (previewImageURL) {
        [self.previewImage imageWithUrl:previewImageURL completion:^(UIImage *image) {
            // Sanity check
            if ([self.message.messageID isEqualToString:messageID]) {
                self.previewImage.image = image;
            }
        }];
        self.previewImageHeightConstraint.constant = 240.0;
    } else {
        self.previewImage.image = nil;
        self.previewImageHeightConstraint.constant = 0.0;
    }

    self.titleLabel.text = self.message.title;

    self.subtitleLabel.text = [self subtitleText];

    if (self.message.unread) {
        self.unreadImage.image = [UIImage imageNamed:@"New_Message"];
    } else {
        self.unreadImage.image = [UIImage imageNamed:@"Read_Message"];
    }
}

- (NSString *)previewImageUrl
{
    NSDictionary *icons = [self.message.rawMessageObject objectForKey:@"icons"];
    NSString *previewImageURL = [icons objectForKey:@"list_icon"];

    if (!previewImageURL) {
        previewImageURL = [self.message.extra objectForKey:@"COVER_IMAGE"];
    }

    return previewImageURL;
}

- (NSString *)subtitleText
{
    return [self.message.extra objectForKey:@"com.urbanairship.listing.field1"];
}

@end
