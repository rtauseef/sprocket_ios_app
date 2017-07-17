# HPPhotoProvider

[![CI Status](http://img.shields.io/travis/Hewlett-Packard/HPPhotoProvider.svg?style=flat)](https://travis-ci.org/Hewlett-Packard/HPPhotoProvider)
[![Version](https://img.shields.io/cocoapods/v/HPPhotoProvider.svg?style=flat)](http://cocoadocs.org/docsets/HPPhotoProvider)
[![License](https://img.shields.io/cocoapods/l/HPPhotoProvider.svg?style=flat)](http://cocoadocs.org/docsets/HPPhotoProvider)
[![Platform](https://img.shields.io/cocoapods/p/HPPhotoProvider.svg?style=flat)](http://cocoadocs.org/docsets/HPPhotoProvider)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

HPPhotoProvider is in a private repository. To install it, you need to have access to that repository and simply add the following line to your Podfile:

    pod "HPPhotoProvider"

## Configuration

After installing you need to configure your project to use the social networks: 

1) Create app ids in each social network for your application.

Instagram:
a) Go to http://instagram.com/developer/clients/manage/ and select the option "Register a New Client".
b) Select an "Application Name", an "OAuth redirect_uri" and make sure the option "Disable implicit OAuth" is selected.


2) Configure to AppDelegate for those social networks that requires (Facebook, Google, Qzone):

a) Configure the delegate method application:openURL:sourceApplication:annotation :

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.scheme isEqual:@"<Google scheme>"]) {
        return [[HPPRGoogleLoginProvider sharedInstance] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    } else if ([url.scheme isEqual:@"<Qzone scheme>"]) {
        return [[HPPRQzoneLoginProvider sharedInstance] handleApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    } else {
        return [[HPPRFacebookLoginProvider sharedInstance] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    }
}

3) Configure the <application>info.plist file:

a) Add URL schemes for Facebook:


URL types
	Item 0
		URL Schemes
			Item 0 <fb<Facebook App Id>>  (for example fb651104071665196)



b) Add FacebookAppID <Facebook App Id> (for example 651104071665196)

c) Add FacebookDisplayName <Facebook Display Name> (for example HP Greeting Cards)

4) Configure Instagram and QZone in HPPR:

a) Configure Instagram:

a-1) clientId

[HPPR sharedInstance].instagramClientId = @"bc44f756f86945fc83f8b43e0a35a91c";

a-2) redirectUrl

[HPPR sharedInstance].instagramRedirectURL = @"hpgcig://callback";


b) Configure Qzone:

b-1) appId

[HPPR sharedInstance].qzoneAppId = @"222222";

b-2) redirectUrl

[HPPR sharedInstance].qzoneRedirectURL = @"www.qq.com";


## Author

HP, support@hp.com

## License

HPPhotoProvider is available under the MIT license. See the LICENSE file for more info.

