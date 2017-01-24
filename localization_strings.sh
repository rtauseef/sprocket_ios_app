#!/bin/bash

# Generate Xliff files of Sprocket App
xcodebuild -exportLocalizations -localizationPath ./localizations/sprocket/ -project Sprocket/Sprocket.xcodeproj -exportLanguage en

#generate Localizable.strings of ios-print-sdk
genstrings -o localizations/ios-print-sdk/ -s MPLocalizedString Pods/MobilePrintSDK/Pod/Classes/Public/*.m Pods/MobilePrintSDK/Pod/Classes/Private/*.m

#generate Localizable.strings of ios-print-sdk
genstrings -o localizations/hp-photo-provider/ -s HPPRLocalizedString Pods/HPPhotoProvider/Pod/Classes/*.m
