# link_with ['SpotHopper', 'SpotHopperTests']

platform :ios, '7.0'

# Networking
pod 'AFNetworking', '~> 2.0.3'
pod 'JSONAPI', :git => 'http://github.com/joshdholtz/jsonapi-ios.git'

# Helpers
pod 'Promises', :git => 'http://github.com/joshdholtz/ios-promises.git'

# UI
pod 'JHAccordion', :git => 'https://github.com/joshdholtz/JHAccordion.git'
pod 'JHAutoCompleteTextField', :git => 'http://github.com/joshdholtz/JHAutoCompleteTextField.git'
pod 'JHSidebar', :git => 'https://github.com/joshdholtz/JHSidebar.git'
pod 'TTTAttributedLabel', '~> 1.8.1'
pod 'MBProgressHUD', '~> 0.8.0'

# Debugging
pod 'Raven', '~> 0.3.0'

# Social
pod 'Facebook-iOS-SDK', '~> 3.11.0'
pod 'STTwitter', '~> 0.0.7'

# Analytics
pod 'Mixpanel', '~> 2.3.0'
pod 'GoogleAnalytics-iOS-SDK', '~> 3.0.0'

target "SpotHopperLocal" do
    # Debugging UI
    pod 'Reveal-iOS-SDK'
end

target "SpotHopperDev" do
    # Debugging UI
    pod 'Reveal-iOS-SDK'
end

target "SpotHopperStaging" do
    # Debugging UI
    pod 'Reveal-iOS-SDK'
end

target "SpotHopperProduction" do
    # Hack to get production building - needed a pod in this target so duplicating AFNetworking
    # NEED TO FIX LATER
    pod 'AFNetworking', '~> 2.0.3'
end