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

#import "PGSelectAlbumDropDownViewController.h"
#import <HPPRSelectAlbumTableViewCell.h>


@implementation PGSelectAlbumDropDownViewController

@dynamic delegate;

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    HPPRSelectAlbumTableViewCell *cell = (HPPRSelectAlbumTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];

    if ([self.delegate respondsToSelector:@selector(selectAlbumDropDownController:didSelectAlbum:)]) {
        [self.delegate selectAlbumDropDownController:self didSelectAlbum:cell.album];
    }
}

@end
