platform :ios, '8.0'
workspace 'Sprocket.xcworkspace'

source 'https://github.com/IPGPTP/hp_mss_pods.git'
source 'https://github.com/CocoaPods/Specs.git'

target "Sprocket"
target "Sprocket-cal"

project 'Sprocket/Sprocket.xcodeproj'

pod 'GoogleAnalytics-iOS-SDK', '3.12'
pod 'TTTAttributedLabel', '1.10.1'
pod 'CocoaLumberjack', '2.2.0'
pod 'MobilePrintSDK', git:'https://github.com/IPGPTP/ios-print-sdk.git', branch:'bluetooth'#path:'/work/ios-print-sdk'#
pod 'HPPhotoProvider', git:'https://github.com/IPGPTP/hp_photo_provider', branch:'master'#path:'~/workspace/hp_photo_provider'#
#pod 'ZipArchive', '1.4.0'

target "Sprocket Print" do
    pod 'MobilePrintSDK', git:'https://github.com/IPGPTP/ios-print-sdk.git', branch:'bluetooth'#path:'/work/ios-print-sdk'#
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if target.name != 'Sprocket Print'
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'TARGET_IS_EXTENSION=1']
            end
        end
    end
end
