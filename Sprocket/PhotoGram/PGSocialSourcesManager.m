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
#import "PGLinkSettings.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoSetting) name:kPGLinkSettingsChangedNotification object:nil];
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

-(void) updateVideoSetting {
    BOOL videoPrintEnabled = [PGLinkSettings videoPrintEnabled];
    for(PGSocialSource * src in self.socialSources) {
        src.photoProvider.displayVideos = videoPrintEnabled;
    }
}

- (void)setupSocialSources
{
    NSMutableArray<PGSocialSource *> *sources = [NSMutableArray array];
    
    if ([NSLocale isChinese]) {
        [sources addObject:[[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeLocalPhotos]];
//        [sources addObject:[[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeWeiBo]];
        [sources addObject:[[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeQzone]];
        [sources addObject:[[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypePitu]];
        [sources addObject:[[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeFacebook]];
        [sources addObject:[[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeInstagram]];
    } else {
        [sources addObject:[[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeInstagram]];
        [sources addObject:[[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeFacebook]];
        [sources addObject:[[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeFlickr]];
        [sources addObject:[[PGSocialSource alloc] initWithSocialSourceType:PGSocialSourceTypeLocalPhotos]];
    }


    self.socialSources = sources;
    [self updateVideoSetting];
}

@end
