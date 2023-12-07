# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ClickMe' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ClickMe
  pod 'XLPagerTabStrip', '~> 9.0'
  pod 'SwiftRangeSlider', '~> 2.0'
  pod 'ScrollingContentViewController'
  pod 'KeyboardDismisser'
  pod 'BadgeSwift', '~> 8.0'
  pod 'CRRefresh'
  pod 'SwipeCellKit'
  pod 'GrowingTextView', '0.6.1'
  pod 'FMSecureTextField'
  pod 'FSCalendar'
  pod 'Cosmos', '~> 23.0'
  pod 'LocationPicker'
  pod 'ExpandableLabel'
  pod "WSTagsField"
  pod 'Alamofire', '~> 5.2'
  pod 'Kingfisher', '~> 7.0'
  pod 'Valet'
  pod 'MonthYearPicker', '~> 4.0.2'
  pod 'AGEVideoLayout'
  pod 'AgoraAudio_iOS'
  pod 'AgoraMediaPlayer_iOS'
  pod 'lottie-ios'
  pod 'ImageViewer'
  pod 'UILabel+Copyable', '~> 2.0'
  pod 'M13Checkbox'
  pod 'Mantis', '~> 1.7.2'
  pod 'JZCalendarWeekView'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
      end
    end
  end
end
