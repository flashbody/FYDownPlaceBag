#
# Be sure to run `pod lib lint BNDDownPlaceBag.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
# pod repo push BNDDownPlaceBagSpec BNDDownPlaceBag.podspec --allow-warnings
# pod lib lint --allow-warnings
# pod spec lint --allow-warnings

Pod::Spec.new do |s|
  s.name             = 'BNDDownPlaceBag'
  s.version          = '0.1.3'
  s.summary          = 'A short description of BNDDownPlaceBag.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/yfs/BNDDownPlaceBag'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yfs' => '742043728@qq.com' }
  s.source           = { :git => 'http://192.168.13.215/BND/BNDDownPlaceBag.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
  s.static_framework = true
  s.source_files = 'BNDDownPlaceBag/Classes/**/*{.h,.m,.pch}'
  s.prefix_header_contents = '#import "BNDDownPlaceBagPrefixHeader.pch"'
  # s.resource_bundles = {
  #   'BNDDownPlaceBag' => ['BNDDownPlaceBag/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
#   s.dependency 'AFNetworking', '~> 4.0.1'
    s.dependency 'YTKNetwork'#,'3.0.0'
    s.dependency 'AFNetworking'
    s.dependency 'Masonry'
    s.dependency 'SVProgressHUD'
#    s.dependency 'SL_SDKRepository'
    s.dependency 'SSZipArchive'
end
