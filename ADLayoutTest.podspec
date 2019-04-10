Pod::Spec.new do |s|
  s.name             = 'ADLayoutTest'
  s.version          = '0.1.0'
  s.summary          = 'Random layout tests.'
  s.homepage         = 'http://github.com/applidium/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'Pierre Felgines'
  s.source           = { :git => 'https://github.com/Pierre Felgines/ADLayoutTest.git', :tag => "#v{s.version}" }
  s.ios.deployment_target = '9.0'
  s.source_files = 'ADLayoutTest/Classes/**/*'
  s.frameworks = 'UIKit', 'XCTest'
  s.dependency 'ADAssertLayout', '~> 0.1'
  s.dependency 'SwiftCheck', '~> 0.12'
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
end
