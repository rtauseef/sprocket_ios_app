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

#import "PGSocialSourcesManager.h"
#import "NSLocale+Additions.h"

static NSString * const kEnableExtraSocialSourcesKey = @"com.hp.hp-sprocket.enableExtraSocialSources";

@interface PGSocialSourcesManager ()

@property (nonatomic, strong) NSArray<PGSocialSource *> *socialSources;

@end

@implementation PGSocialSourcesManager

+ (instancetype)sharedInstance
{
    static PGSocialSourcesManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PGSocialSourcesManager alloc] init];
    });

    return instance;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        [self setupSocialSources];
    }

    return self;
}

- (NSArray<PGSocialSource *> *)enabledSocialSources
{
    return self.socialSources;
}

- (PGSocialSource *)socialSourceByType:(PGSocialSourceType)type
{
    for (PGSocialSource *socialSource in self.socialSources) {
        if (socialSource.type == type) {
            return socialSource;
        }
    }
    
    return nil;
}

- (PGSocialSource *)socialSourceByTitle:(NSString *)title
{
    for (PGSocialSource *socialSource in self.socialSources) {
        if ([socialSource.title isEqualToString:title]) {
            return socialSource;
        }
    }
    
    return nil;
}


#pragma mark - Feature Flag

- (BOOL)isEnabledExtraSocialSources
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kEnableExtraSocialSourcesKey];
}

- (void)toggleExtraSocialSourcesEnabled
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL enabled = [userDefaults boolForKey:kEnableExtraSocialSourcesKey];

    [userDefaults setBool:!enabled forKey:kEnableExtraSocialSourcesKey];
    [userDefaults synchronize];
}


#pragma mark - Private

- (void)setupSocialSources
{
    NSString *language = [NSLocale languageID];

    if (![self isEnabledExtraSocialSources]) {
        language = nil;
    }

    if (true){//[language isEqualToString:@"zh"]) {
        self.socialSources = @[
                               [[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeLocalPhotos],
//                               [[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeWeiBo],
                               [[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeQzone],
                               [[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypePitu],
                               [[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeInstagram],
                               [[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeFacebook]
                               ];
        return;
    }

    self.socialSources = @[
                           [[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeInstagram],
                           [[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeFacebook],
                           [[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeFlickr],
                           [[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeLocalPhotos]
                           ];
}

@end
