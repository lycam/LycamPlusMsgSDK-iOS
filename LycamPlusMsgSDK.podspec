#
# Be sure to run `pod lib lint LycamPlusMsgSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LycamPlusMsgSDK"
  s.version          = "0.1.3"
  s.summary          = "A short description of LycamPlusMsgSDK for IM LycamPlus."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://coding.net/u/lycam/p/LycamPlusMsgSDK-iOS/git"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "no777" => "wt@lycam.tv" }
  s.source           = { :git => "https://git.coding.net/lycam/LycamPlusMsgSDK-iOS.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'LycamPlusMsgSDK/Classes/**/*'
#  s.resource_bundles = {
#    'LycamPlusMsgSDK' => ['LycamPlusMsgSDK/Assets/*.png']
#  }

  
  s.public_header_files = [
    'LycamPlusMsgSDK/Classes/*.h'
  ]
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency  'MQTTClient', '~> 0.7.4'
  s.dependency  'MQTTClient/Websocket', '~> 0.7.4'
end
