Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "HIChat"
s.module_name = "HIChat"
s.summary = "Halcyon Innovation chat."
s.requires_arc = true
s.version = "1.1.6"
s.author = { "Vlad Getman" => "ibrightsider@gmail.com" }

s.license = { :type => "MIT", :file => "LICENSE" }
s.homepage = "https://github.com/HalcyonLA/HIChat"
s.source = { :git => "https://github.com/HalcyonLA/HIChat.git", :tag => "#{s.version}"}

s.framework = "UIKit"

s.default_subspec = 'Core'

 s.subspec 'Core' do |cs|
 	cs.source_files = "Source/**/*.{swift}"
    cs.dependency 'HalcyonInnovationKit/Network', '~> 1.3.6'
    cs.dependency 'HIChat/Input'
 end

 s.subspec 'Input' do |si|
	si.source_files = "Source/{HIMessageInputView,HITextView}.{swift}"
	si.dependency 'SZTextView', '~> 1.3'
	si.dependency 'DAKeyboardControl', '~> 2.4.0'
	si.dependency 'HalcyonInnovationKit/UI', '~> 1.3.6'
	si.ios.resource_bundle = { 'HIChat' => '*.xcassets' }
 end

end