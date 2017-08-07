Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "HIChat"
s.module_name = "HIChat"
s.summary = "Halcyon Innovation chat."
s.requires_arc = true
s.version = "1.0.3"
s.author = { "Vlad Getman" => "ibrightsider@gmail.com" }

s.license = { :type => "MIT", :file => "LICENSE" }
s.homepage = "https://github.com/HalcyonLA/HIChat"
s.source = { :git => "https://github.com/HalcyonLA/HIChat.git", :tag => "#{s.version}"}

s.framework = "UIKit"

s.dependency 'HalcyonInnovationKit/Network', '~> 1.2.7'
s.dependency 'SZTextView', '~> 1.3'
s.dependency 'DAKeyboardControl', '~> 2.4.0'

s.source_files = "Source/**/*.{swift}"
s.ios.resource_bundle = { 'HIChat' => '*.xcassets' }

end