platform :ios, '14.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

def app_pods
  # UI
  pod 'EmptyDataSet-Swift'
  pod 'SnapKit'
  pod 'SwiftValidators', :inhibit_warnings => true
  pod 'Presentr'
  pod 'QRCode', :git => 'https://github.com/andrewcampoli/QRCode.git', :inhibit_warnings => true
  pod 'ShimmerSwift'
  pod 'TOCropViewController'
  pod 'PickerView'
end

def api_pods
  # Network
  pod 'Alamofire', '~> 4.9.1'
  pod 'AlamofireImage', '~> 3.6.0'
  pod 'AlamofireNetworkActivityIndicator', '~> 2.4.0'
  pod 'AlamofireObjectMapper', '~> 5.2.1'

  # Data Parsing
  pod 'SwiftyJSON', '5.0.0'
  pod 'ObjectMapper', :inhibit_warnings => true

  # Security
  pod 'Valet', '3.2.8'
end

def shared_pods
  # Dev Tools
  pod 'SwiftLint'
  pod 'Sentry'
end

target 'RaceSync' do
  app_pods
  shared_pods
end

target 'RaceSyncTests' do
  app_pods
  shared_pods
end

target 'RaceSyncAPI' do
  api_pods
  shared_pods
end

target 'RaceSyncAPITests' do
  api_pods
  shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end

    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
              config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
              config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
              config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            end
        end
    end
end
