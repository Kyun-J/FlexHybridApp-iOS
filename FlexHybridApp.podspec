#
#  Be sure to run `pod spec lint FlexHybridApp.podspce.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "FlexHybridApp"
  spec.version      = "1.0.3"
  spec.summary      = "FlexibleHybridApp-iOS"
  spec.ios.deployment_target = '10.0'
  spec.swift_version = '5.5.2'
  spec.author        = { "Kyun-J" => "dvkyun@gmail.com" }
  spec.source       = { :git => "https://github.com/Kyun-J/FlexHybridApp-iOS.git", :tag => "#{spec.version}" }
  spec.license      = { :type => "BSD", :file => "license" }
  spec.source_files = "framework/flexhybridapp/*.{swift,xib}", "framework/flexhybridapp/util/*.swift"
  spec.resources = "framework/flexhybridapp/js/*.js"
  spec.description  = <<-DESC
  FlexibleHybridApp iOS Version
                   DESC

  spec.homepage     = "https://github.com/Kyun-J/FlexHybridApp-iOS"

end
