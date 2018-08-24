Pod::Spec.new do |s|
  s.name             = 'YangSliderView'
  s.version          = '1.0.1'
  s.summary          = 'A short description of YangSliderView.'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/xilankong/YangSliderView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xilankong' => 'xilankong@126.com' }
  s.source           = { :git => 'https://github.com/xilankong/YangSliderView.git', :tag => s.version.to_s }
  s.swift_version = '4.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'YangSliderView/Classes/**/*'
  
end
