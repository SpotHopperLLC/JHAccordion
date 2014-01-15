require 'fileutils'

TEST_FLIGHT_API_TOKEN = "7fd97a55018768eba4c03aaa5a77b739_Mjk5MTczMjAxMi0wMi0wMSAxMDowNzo0OC45NDU0NTI"
TEST_FLIGH_TEAM_TOKEN = "ac0b1816346c2b56b201ae938097833a_MzI0NDcyMjAxNC0wMS0xNCAxNDoyNDoyMi42Mzc4MDM"

PROJDIR="#{File.dirname(__FILE__)}"
WORKSPACE="SpotHopper.xcworkspace"
SCHEME="SpotHopper"
CONFIGURATION="Release"
TARGET_SDK="iphoneos"
#CONFIGURATION_BUILD_DIR="${PROJDIR}/Build/"
PROJECT_BUILDDIR="${CONFIGURATION_BUILD_DIR}"
APPLICATION_BASE_NAME="SpotHopper"
BUILD_HISTORY_DIR="/Users/josh/Dropbox/RokkinCat/Projects/\"Client Projects\"/SpotHopper/Builds/iOS"
DEVELOPPER_NAME="iPhone Developer: Josh Holtz (M57ML2945L)"
PROVISONNING_PROFILE="/Users/josh/iOS/ProvisionProfiles/RokkinCat_Team.mobileprovision"

namespace :build do
  task :prepare do |t|
  	version = ENV['version']
  	build = ENV['build']

  	if version.nil? || build.nil?
  		puts "Mission arguments version= and build="
  		exit(-1)
  	end

  	$APPLICATION_NAME = "#{APPLICATION_BASE_NAME}-v#{version}-b#{build}"

	#FileUtils.mkdir_p BUILD_HISTORY_DIR

    settings = `xctool -workspace #{WORKSPACE} -scheme #{SCHEME} -configuration #{CONFIGURATION} -showBuildSettings build`
    settings.each_line do |line|
    	if line.include? "CONFIGURATION_BUILD_DIR"
    		$CONFIGURATION_BUILD_DIR = line.partition('=').last.strip
    	end
    end
  end

  desc "Builds app"
  task :app => :prepare do
  	if $CONFIGURATION_BUILD_DIR
    	system("xctool -workspace #{WORKSPACE} -scheme #{SCHEME} -sdk #{TARGET_SDK} -configuration #{CONFIGURATION} build")
    end
  end

  desc "Makes IPA"
  task :ipa => :prepare do
  	if $CONFIGURATION_BUILD_DIR
    	system("xcrun -sdk #{TARGET_SDK} PackageApplication #{$CONFIGURATION_BUILD_DIR}/#{APPLICATION_BASE_NAME}.app -o #{BUILD_HISTORY_DIR}/#{$APPLICATION_NAME}.ipa --sign \"#{DEVELOPPER_NAME}\" --embed #{PROVISONNING_PROFILE}")
    end
  end

  desc "Sends to TestFlight"
  task :testflight => :prepare do
  	ipa = "#{BUILD_HISTORY_DIR}/#{$APPLICATION_NAME}.ipa"

  	puts "\n\nTestFlight - about to send #{ipa}"
  	puts "Notes: "
  	notes = STDIN.gets.chomp
  	puts "Notify (type 'true' to notify): "
  	notify = STDIN.gets.chomp == 'true' ? "True" : "False"

  	system("curl http://testflightapp.com/api/builds.json -F file=@#{ipa} -F api_token='#{TEST_FLIGHT_API_TOKEN}' -F team_token='#{TEST_FLIGH_TEAM_TOKEN}' -F notes='#{notes}' -F notify=#{notify}")
  end

end

desc "Run the build"
task :build => ['build:app', 'build:ipa'] do
  
end

desc "Run the AFNetworking Tests for iOS & Mac OS X"
task :test do
	test_success = system("xctool -workspace SpotHopper.xcworkspace/ -scheme SpotHopper -sdk iphonesimulator test")
	if test_success
		puts "\033[0;32m** All tests executed successfully"
	else
		exit(-1)
	end
end

task :default => 'test'
