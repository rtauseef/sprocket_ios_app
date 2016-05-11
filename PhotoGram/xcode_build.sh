#!/bin/bash

rm -rf ../DerivedData
xcodebuild -workspace ../PhotoGram.xcworkspace/ -scheme PhotoGram-Calabash -configuration Debug -sdk iphonesimulator
xcodebuild -workspace ../PhotoGram.xcworkspace/ -scheme PhotoGram-cal -configuration Release -sdk iphonesimulator
xcodebuild -workspace ../PhotoGram.xcworkspace/ -scheme PhotoGram-cal -configuration Release -destination generic/platform=iOS build
