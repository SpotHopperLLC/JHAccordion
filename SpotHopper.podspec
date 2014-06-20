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

  s.prefix_header_contents = '#import "Constants.h"', '<Raven/RavenClient.h>', '#import <Promises/Promise.h>'

  s.source_files = 'SpotHopper/Constants.h', 'SpotHopper/**/DrinkListRequest.{h,m}', 'SpotHopper/**/SpotListRequest.{h,m}', 
      'SpotHopper/**/NSArray+HoursOfOperation.{h,m}', 'SpotHopper/**/NSNumber+Currency.{h,m}', 'SpotHopper/**/SHStyleKit.{h,m}',
      'SpotHopper/**/ClientSessionManager.{h,m}', 'SpotHopper/**/SHJSONAPIResource.{h,m}', 'SpotHopper/**/*Model.{h,m}'

  s.requires_arc = true

  s.dependency 'AFNetworking', '~> 2.0.0'
  s.dependency 'JSONAPI', '~> 0.1.0'
  s.dependency 'Promises', '~> 0.1.0'
  s.dependency 'Raven', '~> 0.2.0'
  s.dependency 'Facebook-iOS-SDK', '~> 3.0'
  s.dependency 'Parse-iOS-SDK', '~> 1.2.19'

end
