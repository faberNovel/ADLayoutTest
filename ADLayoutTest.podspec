Pod::Spec.new do |s|
  s.name             = 'ADLayoutTest'
  s.version          = '1.0.0'
  s.summary          = 'Random layout tests.'
  s.homepage         = 'https://github.com/faberNovel/ADLayoutTest'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'Pierre Felgines'
  s.source           = { :git => 'https://github.com/faberNovel/ADLayoutTest.git', :tag => "v#{s.version}" }
  s.swift_version = '5.1'
  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.source_files = 'ADLayoutTest/Classes/**/*'
  s.frameworks = 'UIKit', 'XCTest'
  s.dependency 'ADAssertLayout', '~> 1.0'
  s.dependency 'SwiftCheck', '~> 0.12'
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
end
