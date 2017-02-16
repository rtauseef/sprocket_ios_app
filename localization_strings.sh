#!/bin/bash

# Generate Xliff files of Sprocket App
xcodebuild -exportLocalizations -localizationPath ./localizations/sprocket/ -project Sprocket/Sprocket.xcodeproj -exportLanguage en

# Copying strings file needed
cp Sprocket/PhotoGram/en.lproj/InfoPlist.strings localizations/sprocket/en.lproj/
cp Sprocket/PhotoGram/Resources/Settings.bundle/en.lproj/Root.strings localizations/sprocket/settings/en.lproj/

# Generate Localizable.strings of ios-print-sdk
genstrings -o localizations/ios-print-sdk/en.lproj/ -s MPLocalizedString Pods/MobilePrintSDK/Pod/Classes/Public/*.m Pods/MobilePrintSDK/Pod/Classes/Private/*.m Pods/MobilePrintSDK/Pod/Classes/Private/Manta/*.m Pods/MobilePrintSDK/Pod/Classes/Private/Malta/*.m

# Generate Localizable.strings of hp-photo-provider
genstrings -o localizations/hp-photo-provider/en.lproj/ -s HPPRLocalizedString Pods/HPPhotoProvider/Pod/Classes/*.m Pods/HPPhotoProvider/Pod/Classes/Additions/*.m
