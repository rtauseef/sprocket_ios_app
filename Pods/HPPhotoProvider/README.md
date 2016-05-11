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


2) Configure to AppDelegate for those social networks that requires (Facebook, Flickr):

a) Configure the delegate method application:openURL:sourceApplication:annotation :

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.scheme isEqual:@"<Flikr scheme>"]) {
        return [[HPPRFlickrLoginProvider sharedInstance] handleOpenURL:url sourceApplication:sourceApplication];
    } else {
        return [[HPPRFacebookLoginProvider sharedInstance] handleOpenURL:url sourceApplication:sourceApplication];
    }
}

NOTE: <Flickr scheme> should be the same you configured when the Flickr application id was created (for example hpgcflickr).


3) Configure the <application>info.plist file:

a) Add URL schemes for Facebook and Flickr:


URL types
	Item 0
		URL Schemes
			Item 0 <Flikr scheme> (for example hpgcflickr)
			Item 1 <fb<Facebook App Id>>  (for example fb651104071665196)



b) Add FacebookAppID <Facebook App Id> (for example 651104071665196)

c) Add FacebookDisplayName <Facebook Display Name> (for example HP Greeting Cards)

4) Configure Instagram and Flickr in HPPR:

a) Configure Instagram:

a-1) clientId

[HPPR sharedInstance].instagramClientId = @"bc44f756f86945fc83f8b43e0a35a91c";

a-2) redirectUrl

[HPPR sharedInstance].instagramRedirectURL = @"hpgcig://callback";


b) Configure Flickr:

b-1) flickrAuthCallbackURL

[HPPR sharedInstance].flickrAuthCallbackURL = @"hpgcflickr://callback";

b-2) flickrAppKey

[HPPR sharedInstance].flickrAppKey = @"609e80fb396e9cef3f153e6a6c24145b";

b-3) flickrAppSecret

[HPPR sharedInstance].flickrAppSecret = @"3597009f3552db04";


## Author

HP, support@hp.com

## License

HPPhotoProvider is available under the MIT license. See the LICENSE file for more info.

