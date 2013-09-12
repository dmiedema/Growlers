platform :ios, '6.0'
pod 'AFNetworking', '~> 1'
#pod 'DerpKit'
#pod 'TestFlightSDK'
pod 'HockeySDK'
#pod 'MYIntroduction', :git => 'https://github.com/MatthewYork/iPhone-IntroductionTutorial.git'
pod 'SparkInspector'
pod 'NewRelicAgent'
pod 'Tapstream'
pod 'GoogleAnalytics-iOS-SDK'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Pods-acknowledgements.plist', 'Growlers/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
