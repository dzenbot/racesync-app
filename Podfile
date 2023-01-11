platform :ios, '13.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

# Dev Tools
pod 'SwiftLint'
pod 'Sentry', '~> 4.4.1'

target 'RaceSync' do
  # UI
  pod 'EmptyDataSet-Swift'
  pod 'SnapKit'
  pod 'SwiftValidators', :inhibit_warnings => true
  pod 'Presentr'
  pod 'QRCode', :git => 'https://github.com/andrewcampoli/QRCode.git', :inhibit_warnings => true
  pod 'ShimmerSwift'
  pod 'TOCropViewController'
  pod 'PickerView'
  # pod 'TwitterTextEditor'
  # pod "RichEditorView"

  # Analytics

  target 'RaceSyncTests' do
    inherit! :search_paths
  end
end

target 'RaceSyncAPI' do
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

    # Data
#    pod 'RealmSwift', '3.10.0'
#    pod 'ObjectMapper+Realm', '0.6'

    # Rx
#    pod 'RxSwift', '4.3.1'
#    pod 'RxCocoa', '4.3.1'
#    pod 'RxDataSources', '3.1.0'
#    pod 'RxRealm', '0.7.5'

    # Dev Tools
    pod 'SwiftLint'

    target 'RaceSyncAPITests' do
        inherit! :search_paths
    end
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
end
