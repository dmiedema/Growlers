platform :ios, '7.0'
pod 'AFNetworking', '~> 1' # for ground control.
pod 'GroundControl'
#pod 'DerpKit'
pod 'HockeySDK'
pod 'CocoaLumberjack'
#pod 'SparkInspector'
#pod 'NewRelicAgent'
pod 'Tapstream'
#pod 'GoogleAnalytics-iOS-SDK'
#pod 'OHAttributedLabel'

# Testing
pod 'SDScreenshotCapture'


post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Pods-acknowledgements.plist', 'Growlers/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
