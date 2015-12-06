Pod::Spec.new do |s|
  s.name             = "ZSWTappableLabel"
  s.version          = "1.2"
  s.summary          = "UILabel subclass in which substrings links can be tapped"
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

  s.source_files = 'ZSWTappableLabel/**/*'
end
