Pod::Spec.new do |s|
  s.name             = "ZSWTappableLabel"
  s.version          = "1.0"
  s.summary          = "UILabel subclass in which substrings can be tapped"
  s.description      = <<-DESC
                        NSAttributedStrings presented in ZSWTappableLabel can be tapped
                        in subranges you specify using attributes.
                        Read more: https://github.com/zacwest/ZSWTappableLabel
                       DESC
  s.homepage         = "https://github.com/zacwest/ZSWTappableLabel"
  s.license          = 'MIT'
  s.author           = { "Zachary West" => "zacwest@gmail.com" }
  s.source           = { :git => "https://github.com/zacwest/ZSWTappableLabel.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/zacwest'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ZSWTappableLabel' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
