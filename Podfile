platform :ios, '11.0'

target 'RaceSync' do
  use_frameworks!

  # UI
  pod 'EmptyDataSet-Swift'
  pod 'SnapKit'
  pod 'SwiftValidators', :inhibit_warnings => true
  pod 'Presentr'
  pod 'QRCode', :git => 'https://github.com/andrewcampoli/QRCode.git', :inhibit_warnings => true
  pod 'ShimmerSwift'
  pod 'TUSafariActivity', '~> 1.0'
  pod "PickerView"

  # Dev Tools
  pod 'SwiftLint'

  target 'RaceSyncTests' do
    inherit! :search_paths
  end
end

target 'RaceSyncAPI' do
    use_frameworks!

    # Network
    pod 'Alamofire', '~> 4.9.1'
    pod 'AlamofireImage', '~> 3.6.0'
    pod 'AlamofireNetworkActivityIndicator', '~> 2.4.0'
    pod 'AlamofireObjectMapper', '~> 5.2.1'

    # Data Parsing
    pod 'SwiftyJSON'
    pod 'ObjectMapper', :inhibit_warnings => true

    # Security
    pod 'Valet'
    
    # Data
#    pod 'RealmSwift', '3.10.0'
#    pod 'RxRealm', '0.7.5'
#    pod 'ObjectMapper+Realm', '0.6'

    # Rx
#    pod 'RxSwift', '4.3.1'
#    pod 'RxCocoa', '4.3.1'
#    pod 'RxDataSources', '3.1.0'

    # Dev Tools
    pod 'SwiftLint'

    target 'RaceSyncAPITests' do
        inherit! :search_paths
    end
end
