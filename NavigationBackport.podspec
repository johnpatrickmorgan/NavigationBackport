Pod::Spec.new do |spec|
  spec.name                   = "NavigationBackport"
  spec.version                = "0.11.2"
  spec.summary                = "Backports NavigationStack for older SwiftUI versions."
  spec.description            = <<-DESC
  This package uses the navigation APIs available in older SwiftUI versions 
  (such as `NavigationView` and `NavigationLink`) to recreate the new `NavigationStack` APIs 
  introduced in WWDC22, so that you can start targeting those APIs on older versions of iOS, tvOS, 
  macOS and watchOS. When running on an OS version that supports `NavigationStack`, `NavigationStack` 
  will be used under the hood.
                   DESC
  spec.homepage               = "https://github.com/johnpatrickmorgan/NavigationBackport"
  spec.license                = { :type => "MIT", :file => "LICENSE" }
  spec.author                 = { "John Patrick Morgan" => "johnpatrickmorganuk@gmail.com" }
  spec.ios.deployment_target  = "14.0"
  spec.osx.deployment_target  = "11.0"
  spec.watchos.deployment_target = "7.0"
  spec.tvos.deployment_target = "14.0"
  spec.source                 = { :git => "https://github.com/johnpatrickmorgan/NavigationBackport.git", :tag => "#{spec.version}" }
  spec.source_files           = "Sources/NavigationBackport/*.swift"
  spec.framework              = "SwiftUI", "Foundation"
  spec.swift_version          = "5.6"
end
