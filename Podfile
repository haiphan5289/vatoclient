source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

platform :ios, '9.0'

# Firebase
def googleFirebase
    pod 'GoogleSignIn'#, '~> 4.4.0'
    pod 'Firebase/Core'#, '5.13.0'
    pod 'Firebase/Auth'#, '5.13.0'
    pod 'Firebase/Database'#, '5.13.0'
    pod 'Firebase/Storage'#, '5.13.0'
    pod 'Firebase/Messaging'#, '5.13.0'
    pod 'Firebase/DynamicLinks'#, '5.13.0'
    pod 'Firebase/Analytics'
    pod 'Firebase/RemoteConfig'
    pod 'Firebase/Firestore'
end

# Google Map
def googleMap
    pod 'GoogleMaps'#, '2.7.0'
    pod 'GooglePlaces'
    pod 'GoogleAppMeasurement'#, '5.3.0'
end

# Facebook
def facebook
    pod 'FBSDKCoreKit'#, '4.38.1'
    pod 'FBSDKLoginKit'#, '4.38.1'
end

# Vato
def vato
    pod 'VatoFramework', :git => 'https://github.com/vatoio/vato-ios-framework'
end

def prod_and_dev
#    pod 'AFNetworking/UIKit'#, '~> 3.0'
#    pod 'AFNetworking'#, '~> 3.0'
    pod 'JSONModel'
    pod 'UIAlertView+Blocks'
    pod 'LGPlusButtonsView', '~> 1.1.0'
    pod 'SVPullToRefresh'
    pod 'SPSlideTabBarController'
    pod 'KYDrawerController-ObjC'
   
    pod 'RSKImageCropper', '~> 1.6.3'
    pod 'ReactiveCocoa', '2.1.8'
    pod 'JVFloatLabeledTextField'
    pod 'PasscodeView'
    
    pod 'PhoneCountryCodePicker'
    pod 'FCChatHeads'
    pod 'VeeContactPicker'
    pod 'GSKStretchyHeaderView'

    # Crashlytics
    pod 'Fabric'#, '~> 1.9.0'
    pod 'Crashlytics'#, '~> 3.12.0'
    pod 'MomoiOSSwiftSdk', :git => 'https://github.com/momodevelopment/MomoiOSSwiftSdk.git',:branch => "master"
    pod 'SDWebImage'
    pod 'FSCalendar'
    pod 'Firebase/Analytics'
    pod 'KeyPathKit'
    pod 'Zip', '~> 1.1'
    pod 'SDWebImagePDFCoder'
    pod 'AXPhotoViewer/SDWebImage'
    pod "GCDWebServer", "~> 3.0"
    pod 'Atributika'
    
    googleFirebase
    googleMap
    facebook
    vato
end

target 'Vato' do
    prod_and_dev
end

target 'Vato DEV' do
    prod_and_dev
end

target 'Vato Staging' do
    prod_and_dev
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
