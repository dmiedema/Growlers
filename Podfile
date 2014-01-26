platform :ios, '7.0'
pod 'AFNetworking'
pod 'GroundControl'
#pod 'DerpKit'
pod 'HockeySDK'
pod 'CocoaLumberjack'
pod 'UALogger'
#pod 'NewRelicAgent'
pod 'Tapstream'
#pod 'GoogleAnalytics-iOS-SDK'
#pod 'OHAttributedLabel'
#pod 'MessageBarManager'
#pod 'WCFastCell'

# Testing
pod 'SDScreenshotCapture'
pod 'SparkInspector'

target :GrowlersTests, :exclusive => true do
  pod 'Kiwi/XCTest'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Pods-acknowledgements.plist', 'Growlers/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
