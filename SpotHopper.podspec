Pod::Spec.new do |s| 

  s.name         = "SpotHopper"
  s.version      = "2.0.0"
  s.summary      = "SpotHopper"

  s.description  = "SpotHopper main library for reference by secondary apps."

  s.homepage     = "http://www.spothopperapp.com/"

  s.license      = "MIT"

  s.author       = { "Tech" => "tech@spothopperapp.com" }

  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/SpotHopperLLC/SpotHopper-iOS.git", :tag => "Podspec-2.0.0" }
  s.source_files = 'SpotHopper/**/*Model.{h,m}'
  s.source_files = 'SpotHopper/**/SHStyleKit.{h,m}'
  s.requires_arc = true

  s.dependency 'AFNetworking', '~> 2.0.0'
  s.dependency 'JSONAPI', '~> 0.1.0'

end
