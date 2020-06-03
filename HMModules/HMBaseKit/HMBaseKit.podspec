#
# Be sure to run `pod lib lint HMBaseKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HMBaseKit'
  s.version          = '0.0.1'
  s.summary          = 'A short description of HMBaseKit.'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/likaiou@orvibo.com/HMBaseKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'KOLee' => 'likaiou@orvibo.com' }
  s.source           = { :git => 'https://github.com/likaiou@orvibo.com/HMBaseKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'HMBaseKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HMBaseKit' => ['HMBaseKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
