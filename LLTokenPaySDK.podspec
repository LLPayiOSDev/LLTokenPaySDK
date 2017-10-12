Pod::Spec.new do |s|
  s.name             = 'LLTokenPaySDK'
  s.version          = '3.2'
  s.summary          = 'LLTokenPaySDK'

  s.description      = <<-DESC
LLTokenPaySDK是一个支付标记化的SDK， 支持连连支付首创的认证支付， 以及快捷支付、分期付、基金支付等支付方式， 支持短信、TouchID、FaceID等验证方式
                       DESC

  s.homepage         = 'https://github.com/LLPayiOSDev/LLTokenPaySDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LLPayiOSDev' => 'iosdev@yintong.com.cn' }
  s.source           = { :git => 'https://github.com/LLPayiOSDev/LLTokenPaySDK.git', :tag => s.version.to_s }
  s.platform = :ios
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.source_files = 'LLTokenPaySDK/**/*.{h,m}'
  s.public_header_files = 'LLTokenPaySDK/**/*.h'
  s.ios.vendored_library = 'LLTokenPaySDK/libLLTokenPaySDK.a'
  s.resource = 'LLTokenPaySDK/Assets/walletResources.bundle'
end
