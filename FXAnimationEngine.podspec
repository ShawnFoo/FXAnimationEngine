Pod::Spec.new do |spec|
  spec.name         = "FXAnimationEngine"
  spec.version      = "1.0.0"
  spec.summary      = "An engine to play image frames in animation without causing high-memory usage. "

  spec.homepage     = "https://github.com/ShawnFoo/FXAnimationEngine"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Shawn Foo" => "fu4904@gmail.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = "7.0"

  spec.source       = { :git => "https://github.com/ShawnFoo/FXAnimationEngine.git", :tag => "v#{spec.version.to_s}" }
  spec.source_files  = "FXAnimationEngine/*.{h,m}"
  spec.framework  = "UIKit"
  spec.requires_arc = true
end
