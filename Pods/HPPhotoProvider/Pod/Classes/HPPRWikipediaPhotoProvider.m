//
//  HPPRWikipediaPhotoProvider.m
//  Pods
//
//  Created by Fernando Caprio on 5/23/17.
//
//

#import "HPPRWikipediaPhotoProvider.h"
#import "HPPRCameraRollLoginProvider.h"
#import "NSBundle+HPPRLocalizable.h"

@implementation HPPRWikipediaPhotoProvider

+ (HPPRWikipediaPhotoProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRWikipediaPhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRWikipediaPhotoProvider alloc] init];
        sharedInstance.loginProvider = [HPPRCameraRollLoginProvider sharedInstance];
        sharedInstance.loginProvider.delegate = sharedInstance;
    });
    return sharedInstance;
}

#pragma mark - User Interface

- (NSString *)name
{
    return @"Wikipedia";
}

- (NSString *)localizedName
{
    return HPPRLocalizedString(@"Wikipedia", nil);
}

- (BOOL)showSearchButton
{
    return NO;
}


@end
