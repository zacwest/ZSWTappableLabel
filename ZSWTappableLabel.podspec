Pod::Spec.new do |s|
  s.name             = "ZSWTappableLabel"
  s.version          = "3.3"
  s.summary          = "UILabel subclass for links which are tappable, long-pressable, 3D Touchable, and VoiceOverable."
  s.description      = "NSAttributedStrings displayed in ZSWTappableLabel can be tapped, long-pressed, 3D Touched, "\
                       "or interacted with using VoiceOver in substrings you specify using string attributes. "\
                       "Read more: https://github.com/zacwest/ZSWTappableLabel"
  s.homepage         = "https://github.com/zacwest/ZSWTappableLabel"
  s.license          = 'MIT'
  s.author           = { "Zachary West" => "zacwest@gmail.com" }
  s.source           = { :git => "https://github.com/zacwest/ZSWTappableLabel.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/zacwest'

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.ios.framework  = 'UIKit'

  s.private_header_files = 'ZSWTappableLabel/**/Private/*.h'
  s.public_header_files = 'ZSWTappableLabel/*.h'
  s.source_files = 'ZSWTappableLabel/**/*'
end
