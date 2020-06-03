
Pod::Spec.new do |s|
  s.name             = 'HomeMateModule'
  s.version          = '0.0.1'
  s.summary          = 'HomeMateSDK底层模块'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/likaiou@orvibo.com/HomeMateModule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'likaiou@orvibo' => 'likaiou@orvibo.com' }
  s.source           = { :git => 'https://github.com/273307137@qq.com/HomeMateModule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'HomeMateModule/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HomeMateModule' => ['HomeMateModule/Assets/*.png']
  # }
  
  s.compiler_flags = '-DSQLITE_HAS_CODEC', '-DSQLITE_TEMP_STORE=2', '-DSQLCIPHER_CRYPTO_CC', '-DSQLITE_THREADSAFE'
  

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  s.dependency 'SQLCipher'
  s.dependency 'FMDB', '~> 2.4'
  s.dependency 'MJExtension'
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'Reachability'
  s.libraries = 'sqlite3'


end
