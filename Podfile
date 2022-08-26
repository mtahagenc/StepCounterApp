# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'StepCounterApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for StepCounterApp
	pod 'Firebase/Core'
	pod 'Firebase/Auth'
	pod 'Firebase/Firestore'
	pod 'Firebase/Database'
  pod 'Firebase/Storage'
	pod 'OneSignal', '>= 2.11.2', '< 3.0'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  inhibit_all_warnings!

  target 'OneSignalNotificationServiceExtension' do
    #only copy below line
    pod 'OneSignal', '>= 2.11.2', '< 3.0'
end

  target 'StepCounterAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'StepCounterAppUITests' do
    # Pods for testing
  end

end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
end
