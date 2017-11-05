# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

  use_frameworks!

# Ignore all warnings from all pods
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'

target ‘dailybibleverse’ do
  pod 'SwiftyJSON', '~> 3.1'
  pod 'RxSwift', '~> 3.1'
  pod 'Alamofire', '~> 4.2'
  pod 'Bolts'
  pod 'FBSDKCoreKit'
  pod 'FBSDKShareKit'
  pod 'FBSDKLoginKit'
  pod 'Google-Mobile-Ads-SDK'
  pod 'RealmSwift' 

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
