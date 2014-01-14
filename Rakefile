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
