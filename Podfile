
platform :ios, '7.1'

source 'https://github.com/CocoaPods/Specs.git'

def import_pods
    
    # Networking
    pod 'AFNetworking', '~> 2.4'
    pod 'JSONAPI', :git => 'https://github.com/SpotHopperLLC/jsonapi-ios.git', :tag => 'SpotHopper-v2'
    pod 'BitlyForiOS', :git => 'https://github.com/brennanMKE/BitlyForiOS.git', :tag => '1.1.0'

    # Helpers
    pod 'Promises', :git => 'http://github.com/joshdholtz/ios-promises.git'

    # UI
    pod 'JHAccordion', :git => 'https://github.com/SpotHopperLLC/JHAccordion.git', :tag => 'SpotHopper-v2'
    pod 'UIView-Autolayout', '~> 0.2.0'
    pod 'JHAutoCompleteTextField', :git => 'http://github.com/joshdholtz/JHAutoCompleteTextField.git'
    pod 'JHSidebar', :git => 'https://github.com/joshdholtz/JHSidebar.git'
    pod 'TTTAttributedLabel', '~> 1.10'
    pod 'PhotoZoom', '~> 0.0'
    pod 'MBProgressHUD', '~> 0.8.0'
    pod 'UIImage+BlurredFrame', '~> 0.0'
    pod 'BlocksKit', '~> 2.2.0'
    pod 'SVPulsingAnnotationView', '~> 0.3.0'
    pod 'JTSReachability', :git => 'http://github.com/brennanMKE/JTSReachability.git', :tag => '1.1.0'
    pod 'Haneke', '~> 1.0'

    # Debugging
    # pod 'Raven', '~> 0.2.0'
    pod 'CrashlyticsFramework', '~> 2.2'

    # Social
    pod 'Facebook-iOS-SDK', '~> 3.0'
    pod 'STTwitter', '~> 0.1'

    # Push notifications
    pod 'Parse', '~> 1.4'

    # Analytics
    pod 'Mixpanel', '~> 2.5'

end

target "SpotHopperLocal" do
    import_pods
    
    # Debugging UI
    pod 'Reveal-iOS-SDK'
end

target "SpotHopperDev" do
    import_pods
    
    # Debugging UI
    pod 'Reveal-iOS-SDK'
end

target "SpotHopperStaging" do
    import_pods
    
    # Debugging UI
    pod 'Reveal-iOS-SDK'
end

target "SpotHopperProduction" do
    import_pods
end

target "InstantMenuStaging" do
    import_pods
    
    # Debugging UI
    pod 'Reveal-iOS-SDK'
end

target "InstantMenuProduction" do
    import_pods
end
