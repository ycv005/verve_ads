#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint verve_ads.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'verve_ads'
  s.version          = '0.0.1'
  s.summary          = 'Verve (HyBid) Ads Flutter Plugin'
  s.description      = <<-DESC
A comprehensive Flutter plugin for integrating Verve (HyBid) SDK for native advertising.
Provides configurable and scalable ad integration with support for multiple ad formats.
                       DESC
  s.homepage         = 'https://github.com/yourusername/verve_ads'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'HyBid', '~> 3.7.1'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
