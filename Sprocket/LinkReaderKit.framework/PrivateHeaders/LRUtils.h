//
//  HPUtils.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//
@import UIKit;
#import <Foundation/Foundation.h>

@interface LRUtils : NSObject


/**
 Given a localizable key, what is the localized string?

 @discussion This method will look for the key value in the application first, then look for a match in the framework localized strings. It's a rather simple lookup - if the lookup in the application's localized strings returns the same value as the key, it's assumed an appropriate value did not exist, and tries the framework's localized string lookup and used the value returned there. Though it could be wrong (ie, no matching key) in the framework, we assume the localization has been performed properly for all framework code.

 @param key NSLocalizedString key

 @return Localized string value either from the application's localization table, or the framework's
 */
+ (NSString *)localizedStringForKey:(NSString *)key;


/**
 *  Returns the device orientation or calculating based on the UI orientation if device orientation is unknown.
 *  It's not as dumb as it may seem.
 *  This is meant to be a shortcut for a few extra lines of code sprinkled many places over the app
 *
 *  @return UIDeviceOrientation
 *
 *  @since 1.0
 */
+(UIDeviceOrientation)orientation;


/**
 *  Gives us the user interface orientation
 *
 *  @return UIInterfaceOrientation
 *
 *  @since 1.0
 */
+(UIInterfaceOrientation)uiOrientation;

/**
 *  Return the orientation given an orientation. In cases where orientation is unknown, will return a value based
 *  off of the UI orientation. It's not as dumb as it may seem.
 *  This is meant to be a shortcut for a few extra lines of code sprinkled many places over the app.
 *
 *  @param orientation a device orientation
 *
 *  @return Device orientation
 *
 *  @since 1.0
 */
+(UIDeviceOrientation)orientation:(UIDeviceOrientation)orientation;

/**
 *  Is the device landscape? Just a litte helper method. Uses +orientation
 *
 *  @return YES/NO
 *
 *  @since 1.0
 */
+(BOOL)isLandscape;


/**
 *  Is the device portrait? Just a litte helper method. Uses +orientation
 *
 *  @return YES/NO
 *
 *  @since 1.0
 */
+(BOOL)isPortrait;

+(BOOL)isUILandscape;
+(BOOL)isUIPortrait;

/**
 *  For analyics, convert the current UI orientation to a string
 *
 *  @param orientation UIInterfaceOrientation
 *
 *  @return String representation of the orientation
 *
 *  @since 1.0
 */
+ (NSString *)currentInterfaceOrientationToString;

/**
 *  @since 1.1.1
 */
+ (BOOL)isLinkReaderApp;

/**
 *  @since 1.1.2
 */
+ (BOOL)isPartnerApp;

/**
 * Enable or disable conference mode
 *
 * @param isEnabled Boolean
 *
 * @Since 1.2.0
 */
+(void)setConferenceModeEnabled:(Boolean)isEnabled;

/**
 *  Is the app in conference mode? Just a litte helper method.
 *
 *  @return YES/NO
 *
 *  @since 1.2.0
 */
+ (BOOL) isConferenceModeEnabled;

@end
