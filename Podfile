platform :ios, '11.0'

target 'RaceSync' do
  use_frameworks!

  # UI
  pod 'SnapKit'
  pod 'SwiftValidators', :inhibit_warnings => true
  pod 'Presentr'
  pod 'QRCode', :git => 'https://github.com/andrewcampoli/QRCode.git', :inhibit_warnings => true

  # Dev Tools
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SwiftLint'

  target 'RaceSyncTests' do
    inherit! :search_paths
  end

end

target 'RaceSyncAPI' do
    use_frameworks!

    # Network
    pod 'Alamofire'
    pod 'AlamofireImage'
    pod 'AlamofireNetworkActivityIndicator'

    # Data Parsing
    pod 'SwiftyJSON'
    pod 'ObjectMapper', :inhibit_warnings => true
    pod 'AlamofireObjectMapper'
    
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
