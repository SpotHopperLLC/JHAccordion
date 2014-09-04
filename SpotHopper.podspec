Pod::Spec.new do |s| 

  s.name         = "SpotHopper"
  s.version      = "2.0.0"
  s.summary      = "SpotHopper"

  s.description  = "SpotHopper main library for reference by secondary apps."

  s.homepage     = "http://www.spothopperapp.com/"

  s.license = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Tech" => "tech@spothopperapp.com" }

  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/SpotHopperLLC/SpotHopper-iOS.git", :tag => s.version }

  s.requires_arc = true

  s.prefix_header_contents = '#import "Constants.h"', '#import <Raven/RavenClient.h>', '#import <Promises/Promise.h>'

  s.dependency 'AFNetworking', '~> 2.0.0'
  s.dependency 'JSONAPI', '~> 0.2.0'
  s.dependency 'Promises', '~> 0.1.0'
  s.dependency 'Raven', '~> 0.2.0'
  s.dependency 'Facebook-iOS-SDK', '~> 3.0'
  s.dependency 'Parse-iOS-SDK', '~> 1.2.19'
  s.dependency 'UIView-Autolayout', '~> 0.2.0'
  s.dependency 'Mixpanel', '~> 2.3.0'

  s.source_files = 'SpotHopper/Constants.h', 'SpotHopper/**/DrinkListRequest.{h,m}', 'SpotHopper/**/SpotListRequest.{h,m}', 
      'SpotHopper/**/NSArray+HoursOfOperation.{h,m}', 'SpotHopper/**/NSNumber+Currency.{h,m}', 'SpotHopper/**/SHStyleKit.{h,m}','SpotHopper/**/SHJSONAPIResource.{h,m}', 'SpotHopper/**/NetworkHelper.{h,m}','SpotHopper/**/Tracker.{h,m}','SpotHopper/**/Tracker+Events.{h,m}','SpotHopper/**/Tracker+People.{h,m}','SpotHopper/**/*Model.{h,m}','SpotHopper/**/JTSReachabilityResponder.{h,m}','SpotHopper/**/TellMeMyLocation.{h,m}',
      'SpotHopper/**/ClientSessionManager.{h,m}','SHAppConfiguration.{h,m}', 'SpotHopper/**/SHNotifications.{h,m}'

end
