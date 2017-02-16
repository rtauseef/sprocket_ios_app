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

#import "PGPhotoSelection.h"
#import "PGMediaNavigation.h"

@interface PGPhotoSelection ()

@property (nonatomic, assign) BOOL selectionEnabled;

@end

@implementation PGPhotoSelection

+ (instancetype)sharedInstance {
    static PGPhotoSelection *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PGPhotoSelection alloc] init];
    });

    return instance;
}

- (void)beginSelectionMode {
    self.selectionEnabled = YES;

    [[PGMediaNavigation sharedInstance] beginSelectionMode];
}

- (void)endSelectionMode {
    self.selectionEnabled = NO;

    [[PGMediaNavigation sharedInstance] endSelectionMode];
}

- (BOOL)isInSelectionMode {
    return self.selectionEnabled;
}

@end
