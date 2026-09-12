#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ekko_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ekko_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Signalez un bug en un tap : capture, stylo rouge, message.'
  s.description      = <<-DESC
Thin Flutter wrapper over the native ekko SDK.
                       DESC
  s.homepage         = 'https://ekko.bomunto.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bomunto' => 'contact@bomunto.com' }
  s.source           = { :path => '.' }
  # The Swift sources live in the Swift Package Manager layout so that both
  # integration paths (SPM and CocoaPods) compile the very same file.
  s.source_files = 'ekko_flutter/Sources/ekko_flutter/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'Ekko', '~> 1.0'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
