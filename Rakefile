require 'fileutils'
require 'readline'
require 'yaml'

PROJDIR="#{File.dirname(__FILE__)}"

def read_in_text(prompt)
  puts prompt
  STDIN.gets.strip
end

def read_in_file(prompt)
  puts prompt
  Readline.completion_proc = Readline::FILENAME_COMPLETION_PROC
  Readline.readline('', true).strip
end

def load_config!
    if !File.exist?('build_config.yml')
      puts "CONFIGURATION ERROR: Please create a build_config.yml or run 'rake build:config'"
      exit(-1)
    end

    # Loads haml
    build_config = YAML.load_file('build_config.yml')

    # Prepares things we need to know
    # TestFlight
    if build_config['test-flight']
      $test_flight_api_token = build_config['test-flight']['api-token']
      $test_flight_team_token = build_config['test-flight']['team-token']
    end

    # Project
    if build_config['project']
      $workspace = build_config['project']['workspace']
      $application_name = build_config['project']['application-name']
      $scheme = build_config['project']['scheme']
      $configuration = build_config['project']['configuration']
      $target_sdk = build_config['project']['target-sdk']
    end

    # Build
    if build_config['build']
        $output_directory = build_config['build']['output-directory']
        $developer_name = build_config['build']['developer-name']
        $provisioning_profile = build_config['build']['provisioning-profile']
    end

    if $workspace.to_s.strip.length == 0 ||
      $application_name.to_s.strip.length == 0 ||
      $scheme.to_s.strip.length == 0 ||
      $configuration.to_s.strip.length == 0 ||
      $target_sdk.to_s.strip.length == 0
      puts "CONFIGURATION ERROR: Please fix your build_config.yml or run 'rake build:config'"
      exit(-1)
    end

    if $output_directory.to_s.strip.length == 0 ||
      $developer_name.to_s.strip.length == 0 ||
      $provisioning_profile.to_s.strip.length == 0
      puts "CONFIGURATION ERROR: Please fix your build_config.yml or run 'rake build:config'"
      exit(-1)
    end

end

namespace :build do

  task :config do |t|

    # Loads haml
    if File.exist?('build_config.yml')
      build_config = YAML.load_file('build_config.yml')
    else
      build_config = {}
    end

    # Loads
    if build_config['test-flight']
      $test_flight_api_token = build_config['test-flight']['api-token']
      $test_flight_team_token = build_config['test-flight']['team-token']
    else
      build_config['test-flight'] = {}
    end

    # Project
    if build_config['project']
      $workspace = build_config['project']['workspace']
      $application_name = build_config['project']['application-name']
      $scheme = build_config['project']['scheme']
      $configuration = build_config['project']['configuration']
      $target_sdk = build_config['project']['target-sdk']
    else
      build_config['project'] = {}
    end

    # Build
    if build_config['build']
        $output_directory = build_config['build']['output-directory']
        $developer_name = build_config['build']['developer-name']
        $provisioning_profile = build_config['build']['provisioning-profile']
    else
      build_config['build'] = {}
    end

    # READS TESTFLIGHT - API TOKEN
    directions = ""
    directions = "Press enter to use exiting value #{$test_flight_api_token}" if $test_flight_api_token
    prompt = "TestFlight API Token - #{directions}:"
    line = read_in_text(prompt)
    build_config['test-flight']['api-token'] = line if !line.empty?

    # READS TESTFLIGHT - TEAM TOKEN
    directions = ""
    directions = "Press enter to use exiting value #{$test_flight_team_token}" if $test_flight_team_token
    prompt = "TestFlight Team Token - #{directions}:"
    line = read_in_text(prompt)
    build_config['test-flight']['team-token'] = line if !line.empty?

    # READS PROJECT - WORKSPACE
    directions = "Pick file location for .xcworkspace"
    directions = "Press enter to use exiting value #{$workspace}" if $workspace
    prompt = "Workspace - #{directions}:"
    line = read_in_file(prompt)
    build_config['project']['workspace'] = line if !line.empty?

    # READS PROJECT - APPLICATION NAME
    directions = ""
    directions = "Press enter to use exiting value #{$application_name}" if $application_name
    prompt = "Application name - #{directions}:"
    line = read_in_text(prompt)
    build_config['project']['application-name'] = line if !line.empty?

    # READS PROJECT - SCHEME
    directions = ""
    directions = "Press enter to use exiting value #{$scheme}" if $scheme
    prompt = "Scheme - #{directions}:"
    line = read_in_text(prompt)
    build_config['project']['scheme'] = line if !line.empty?

    # READS PROJECT - CONFIGURATION
    directions = ""
    directions = "Press enter to use exiting value #{$configuration}" if $configuration
    prompt = "Conifguration - #{directions}:"
    line = read_in_text(prompt)
    build_config['project']['configuration'] = line if !line.empty?

    # READS PROJECT - TARGET
    directions = ""
    directions = "Press enter to use exiting value #{$target_sdk}" if $target_sdk
    prompt = "Target SDK - #{directions}:"
    line = read_in_text(prompt)
    build_config['project']['target-sdk'] = line if !line.empty?

    # READS BUILD - OUTPUT DIRECTORY
    directions = "Pick directory location for .ipa output directory"
    directions = "Press enter to use exiting value #{$output_directory}" if $provisioning_profile
    prompt = "IPA Output Directory - #{directions}:"
    line = read_in_file(prompt)
    build_config['build']['output-directory'] = line if !line.empty?

    # READS BUILD - DEVELOPER NAME
    directions = ""
    directions = "Press enter to use exiting value #{$developer_name}" if $developer_name
    prompt = "Developer name - #{directions}:"
    line = read_in_text(prompt)
    build_config['build']['developer-name'] = line if !line.empty?

    # READS BUILD - PROVISIONING PROFILE
    directions = "Pick file location for .mobileprovision"
    directions = "Press enter to use exiting value #{$provisioning_profile}" if $provisioning_profile
    prompt = "Provision Profile - #{directions}:"
    line = read_in_file(prompt)
    build_config['build']['provisioning-profile'] = line if !line.empty?

    # Actually writes
    File.open('build_config.yml', 'w') {|f| f.write build_config.to_yaml } #Store

  end

  task :prepare do |t|

   load_config!

    # Prepares stuff for build
  	version = ENV['version']
  	build = ENV['build']

  	if version.nil? || build.nil?
  		puts "Mission arguments version= and build="
  		exit(-1)
  	end

  	$application_output_name = "#{$application_name}-v#{version}-b#{build}"

	  FileUtils.mkdir_p $output_directory

    settings = `xctool -workspace #{$workspace} -scheme #{$scheme} -configuration #{$configuration} -showBuildSettings build`
    settings.each_line do |line|
    	if line.include? "CONFIGURATION_BUILD_DIR"
    		$configuration_build_dir = line.partition('=').last.strip
    	end
    end
  end

  desc "Builds app"
  task :app => :prepare do
  	if $configuration_build_dir
    	system("xctool -workspace #{$workspace} -scheme #{$scheme} -sdk #{$target_sdk} -configuration #{$configuration} build")
    end
  end

  desc "Makes IPA"
  task :ipa => :prepare do
  	if $configuration_build_dir
    	system("xcrun -sdk #{$target_sdk} PackageApplication #{$configuration_build_dir}/#{$application_name}.app -o #{$output_directory}/#{$application_output_name}.ipa --sign \"#{$developer_name}\" --embed #{$provisioning_profile}")
    end
  end

  desc "Sends to TestFlight"
  task :testflight => :prepare do
  	ipa = "#{$output_directory}/#{$application_output_name}.ipa"

  	puts "\n\nTestFlight - about to send #{ipa}"
  	puts "Notes: "
  	notes = STDIN.gets.chomp
  	puts "Notify (type 'true' to notify): "
  	notify = STDIN.gets.chomp == 'true' ? "True" : "False"

  	system("curl http://testflightapp.com/api/builds.json -F file=@#{ipa} -F api_token='#{$test_flight_api_token}' -F team_token='#{$test_flight_team_token}' -F notes='#{notes}' -F notify=#{notify}")
  end

end

desc "Run the build"
task :build => ['build:app', 'build:ipa'] do
  
end

desc "Run the tsests for iOS"
task :test do
	load_config!
	test_success = system("xctool -workspace #{$workspace} -scheme #{$scheme} -sdk iphonesimulator test")
	if test_success
		puts "\033[0;32m** All tests executed successfully"
	else
		exit(-1)
	end
end

#task :default => 'test'
