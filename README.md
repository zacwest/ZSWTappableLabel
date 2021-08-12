# ZSWTappableLabel

<!--[![CI Status](http://img.shields.io/travis/zacwest/ZSWTappableLabel.svg?style=flat)](https://travis-ci.org/zacwest/ZSWTappableLabel)-->
[![Version](https://img.shields.io/cocoapods/v/ZSWTappableLabel.svg?style=flat)](http://cocoapods.org/pods/ZSWTappableLabel)
[![License](https://img.shields.io/cocoapods/l/ZSWTappableLabel.svg?style=flat)](http://cocoapods.org/pods/ZSWTappableLabel)
[![Platform](https://img.shields.io/cocoapods/p/ZSWTappableLabel.svg?style=flat)](http://cocoapods.org/pods/ZSWTappableLabel)

ZSWTappableLabel is a UILabel subclass for links which are tappable, long-pressable, 3D Touchable, and VoiceOverable. It has optional highlighting behavior, and does not draw text itself. Its goal is to be as minimally different from UILabel as possible, and only executes additional code when the user is interacting with a tappable region.

## A basic, tappable link

Let's create a string that's entirely tappable and shown with an underline:

```swift
let string = NSLocalizedString("Privacy Policy", comment: "")
let attributes: [NSAttributedString.Key: Any] = [
  .tappableRegion: true,
  .tappableHighlightedBackgroundColor: UIColor.lightGray,
  .tappableHighlightedForegroundColor: UIColor.white,
  .foregroundColor: UIColor.blue,
  .underlineStyle: NSUnderlineStyle.single.rawValue,
  .link: URL(string: "http://imgur.com/gallery/VgXCk")!
]

label.attributedText = NSAttributedString(string: string, attributes: attributes)
```

```objective-c
NSString *s = NSLocalizedString(@"Privacy Policy", nil);
NSDictionary *a = @{
  ZSWTappableLabelTappableRegionAttributeName: @YES,
  ZSWTappableLabelHighlightedBackgroundAttributeName: [UIColor lightGrayColor],
  ZSWTappableLabelHighlightedForegroundAttributeName: [UIColor whiteColor],
  NSForegroundColorAttributeName: [UIColor blueColor],
  NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
  NSLinkAttributeName: [NSURL URLWithString:@"http://imgur.com/gallery/VgXCk"],
};

label.attributedText = [[NSAttributedString alloc] initWithString:s attributes:a];
```

This results in a label which renders like:

> [Privacy Policy](https://github.com/zacwest/zswtappablelabel)

Setting your controller as the `tapDelegate` of the label results in the following method call when tapped:

```swift
func tappableLabel(
  _ tappableLabel: ZSWTappableLabel, 
  tappedAt idx: Int, 
  withAttributes attributes: [NSAttributedString.Key : Any]
) {
  if let url = attributes[.link] as? URL {
    UIApplication.shared.openURL(url)
  }
}
```

```objective-c
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
  [[UIApplication sharedApplication] openURL:attributes[@"URL"]];
}
```

## Long-presses

You may optionally support long-presses by setting a `longPressDelegate` on the label. This behaves very similarly to the `tapDelegate`:

```swift
func tappableLabel(
  _ tappableLabel: ZSWTappableLabel, 
  longPressedAt idx: Int, 
  withAttributes attributes: [NSAttributedString.Key : Any]
) {
  guard let URL = attributes[.link] as? URL else {
    return
  }
  
  let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
  present(activityController, animated: true, completion: nil)
}
```

```objective-c
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel 
   longPressedAtIndex:(NSInteger)idx 
       withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
  NSURL *URL = attributes[NSLinkAttributeName];
  if ([URL isKindOfClass:[NSURL class]]) {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[ URL ] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
  }
}
```

You can configure the `longPressDuration` for how long until a long-press is recognized. This defaults to 0.5 seconds.

## 3D Touch

If you've registered either the label or a view containing the label for previewing using peek/pop, you can get information about the tappable regions at a point using one of the two `tappableRegionInfo` methods on `ZSWTappableLabel`. See [the header file](https://github.com/zacwest/ZSWTappableLabel/blob/master/ZSWTappableLabel/ZSWTappableLabel.h) for more information.

When you're queried for previewing information, you can respond using the information from these methods. For example, to preview an SFSafariViewController:

```swift
func previewingContext(
  _ previewingContext: UIViewControllerPreviewing, 
  viewControllerForLocation location: CGPoint
) -> UIViewController? {
  guard let regionInfo = label.tappableRegionInfo(
    forPreviewingContext: previewingContext, 
    location: location
  ) else {
    return nil
  }

  guard let URL = regionInfo.attributes[.link] as? URL else {
    return nil
  }

  // convenience method that sets the rect of the previewing context
  regionInfo.configure(previewingContext: previewingContext)
  return SFSafariViewController(url: URL)
}
```

```objc
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
  id<ZSWTappableLabelTappableRegionInfo> regionInfo = 
    [self.label tappableRegionInfoForPreviewingContext:previewingContext location:location];
  if (!regionInfo) {
    return nil;
  }
  [regionInfo configurePreviewingContext:previewingContext];
  return [[SFSafariViewController alloc] initWithURL:regionInfo.attributes[NSLinkAttributeName]];
}
```

## Data detectors

Let's use `NSDataDetector` to find the substrings in a given string that we might want to turn into links:

```swift
let string = "check google.com or call 415-555-5555? how about friday at 5pm?"

let detector = try! NSDataDetector(types: NSTextCheckingAllSystemTypes)
let attributedString = NSMutableAttributedString(string: string, attributes: nil)
let range = NSRange(location: 0, length: (string as NSString).length)

detector.enumerateMatches(in: attributedString.string, options: [], range: range) { (result, flags, _) in
  guard let result = result else { return }
  
  var attributes = [NSAttributedString.Key: Any]()
  attributes[.tappableRegion] = true
  attributes[.tappableHighlightedBackgroundColor] = UIColor.lightGray
  attributes[.tappableHighlightedForegroundColor] = UIColor.white
  attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
  attributes[.init(rawValue: "NSTextCheckingResult")] = result
  attributedString.addAttributes(attributes, range: result.range)
}
label.attributedText = attributedString
```

```objective-c
NSString *string = @"check google.com or call 415-555-5555? how about friday at 5pm?";

NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllSystemTypes error:NULL];
NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:nil];
// the next line throws an exception if string is nil - make sure you check
[detector enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  attributes[ZSWTappableLabelTappableRegionAttributeName] = @YES;
  attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = [UIColor lightGrayColor];
  attributes[ZSWTappableLabelHighlightedForegroundAttributeName] = [UIColor whiteColor];
  attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
  attributes[@"NSTextCheckingResult"] = result;
  [attributedString addAttributes:attributes range:result.range];
}];
label.attributedText = attributedString;
```

This results in a label which renders like:

> check [google.com](#) or call [415-555-5555](#)? how about [friday at 5pm](#)?

We can wire up the `tapDelegate` to receive the checking result and handle each result type when the user taps on the link:

```swift
func tappableLabel(
  tappableLabel: ZSWTappableLabel, 
  tappedAtIndex idx: Int, 
  withAttributes attributes: [NSAttributedString.Key : Any]) {
  if let result = attributes[.init(rawValue: "NSTextCheckingResult")] as? NSTextCheckingResult {
    switch result.resultType {
    case [.address]:
      print("Address components: \(result.addressComponents)")
    case [.phoneNumber]:
      print("Phone number: \(result.phoneNumber)")
    case [.date]:
      print("Date: \(result.date)")
    case [.link]:
      print("Link: \(result.url)")
    default:
      break
    }
  }
}
```

```objective-c
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
  NSTextCheckingResult *result = attributes[@"NSTextCheckingResult"];
  if (result) {
    switch (result.resultType) {
      case NSTextCheckingTypeAddress:
        NSLog(@"Address components: %@", result.addressComponents);
        break;
          
      case NSTextCheckingTypePhoneNumber:
        NSLog(@"Phone number: %@", result.phoneNumber);
        break;
          
      case NSTextCheckingTypeDate:
        NSLog(@"Date: %@", result.date);
        break;
          
      case NSTextCheckingTypeLink:
        NSLog(@"Link: %@", result.URL);
        break;

      default:
        break;
    }
  }
}
```

## Substring linking

For substring linking, I suggest you use [ZSWTaggedString](https://github.com/zacwest/zswtaggedstring) which creates these attributed strings painlessly and localizably. Let's create a more advanced 'privacy policy' link using this library:

> View our [Privacy Policy](https://github.com/zacwest/zswtappablelabel) or [Terms of Service](https://github.com/zacwest/zswtappablelabel)

You can create such a string using a simple ZSWTaggedString:

```swift
let options = ZSWTaggedStringOptions()
options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
  guard let type = tagAttributes["type"] as? String else {
    return [NSAttributedString.Key: Any]()
  }
  
  var foundURL: URL?
  
  switch type {
  case "privacy":
    foundURL = URL(string: "http://google.com/search?q=privacy")!
  case "tos":
    foundURL = URL(string: "http://google.com/search?q=tos")!
  default:
    break
  }
  
  guard let URL = foundURL else {
    return [NSAttributedString.Key: Any]()
  }
  
  return [
    .tappableRegion: true,
    .tappableHighlightedBackgroundColor: UIColor.lightGray,
    .tappableHighlightedForegroundColor: UIColor.white,
    .foregroundColor: UIColor.blue,
    .underlineStyle: NSUnderlineStyle.single.rawValue,
    .link: foundURL
  ]
})

let string = NSLocalizedString("View our <link type='privacy'>Privacy Policy</link> or <link type='tos'>Terms of Service</link>", comment: "")
label.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
```

```objective-c
ZSWTaggedStringOptions *options = [ZSWTaggedStringOptions options];
[options setDynamicAttributes:^NSDictionary *(NSString *tagName, 
                                              NSDictionary *tagAttributes,
                                              NSDictionary *existingStringAttributes) {
  NSURL *URL;
  if ([tagAttributes[@"type"] isEqualToString:@"privacy"]) {
    URL = [NSURL URLWithString:@"http://google.com/search?q=privacy"];
  } else if ([tagAttributes[@"type"] isEqualToString:@"tos"]) {
    URL = [NSURL URLWithString:@"http://google.com/search?q=tos"];
  }

  if (!URL) {
    return nil;
  }

  return @{
    ZSWTappableLabelTappableRegionAttributeName: @YES,
    ZSWTappableLabelHighlightedBackgroundAttributeName: [UIColor lightGrayColor],
    ZSWTappableLabelHighlightedForegroundAttributeName: [UIColor whiteColor],
    NSForegroundColorAttributeName: [UIColor blueColor],
    NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
    @"URL": URL
  };
} forTagName:@"link"];

NSString *string = NSLocalizedString(@"View our <link type='privacy'>Privacy Policy</link> or <link type='tos'>Terms of Service</link>", nil);
label.attributedText = [[ZSWTaggedString stringWithString:string] attributedStringWithOptions:options];
```

## Accessibility

ZSWTappableLabel is an accessibility container, which exposes the substrings in your attributed string as distinct elements. For example, the above string breaks down into:

1. `View our` (static text)
1. `Privacy Policy` (link)
1. ` or ` (static text)
1. `Terms of Service` (link)

This is similar behavior to Safari, which breaks up elements into discrete chunks.

When you set a `longPressDelegate`, an additional action on links is added to perform the long-press gesture. You should configure the `longPressAccessibilityActionName` to adjust what is read to users.

When you set an `accessibilityDelegate`, you can add custom actions to a particular link, for example:

```swift
func tappableLabel(
  _ tappableLabel: ZSWTappableLabel, 
  accessibilityCustomActionsForCharacterRange characterRange: NSRange, 
  withAttributesAtStart attributes: [NSAttributedString.Key : Any] = [:]
) -> [UIAccessibilityCustomAction] {
  return [
    UIAccessibilityCustomAction(
      name: NSLocalizedString("View Link Address", comment: ""),
      target: self,
      selector: #selector(viewLink(_:))
    )
  ]
}
```

```objc
- (NSArray<UIAccessibilityCustomAction *> *)tappableLabel:(ZSWTappableLabel *)tappableLabel
              accessibilityCustomActionsForCharacterRange:(NSRange)characterRange
                                    withAttributesAtStart:(NSDictionary<NSAttributedStringKey,id> *)attributes {
  return @[
    [[UIAccessibilityCustomAction alloc] initWithName:NSLocalizedString(@"View Link Address", nil) 
                                               target:self
                                             selector:@selector(viewLink:)]
  ];
}
```

You can also change the `accessibilityLabel` of the created accessibility elements, for example:

```swift
func tappableLabel(
  _ tappableLabel: ZSWTappableLabel, 
  accessibilityLabelForCharacterRange characterRange: NSRange, 
  withAttributesAtStart attributes: [NSAttributedString.Key : Any] = [:]
) -> String? {
  if attributes[.link] != nil {
    return "Some Custom Label"
  } else {
    return nil
  }
}
```

```objc
- (nullable NSString *)tappableLabel:(nonnull ZSWTappableLabel *)tappableLabel 
 accessibilityLabelForCharacterRange:(NSRange)characterRange 
               withAttributesAtStart:(nonnull NSDictionary<NSAttributedStringKey,id> *)attributes {
  if (attributes[NSLinkAttributeName] != nil) {
    return @"Some Custom Label";
  } else {
    return nil;
  }
}
```


## Installation

ZSWTappableLabel is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "ZSWTappableLabel", "~> 3.3"
```

ZSWTappableLabel is available through [Swift Package Manager](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) in a `Package.swift` like:

```swift
.package(url: "https://github.com/zacwest/ZSWTappableLabel.git", majorVersion: 3)
```

To add it to an Xcode project, add the URL via File > Swift Packages -> Add Package Dependency.

## License

ZSWTappableLabel is available under the [MIT license](https://github.com/zacwest/ZSWTappableLabel/blob/master/LICENSE). This library was created while working on [Free](https://www.producthunt.com/posts/free) who allowed this to be open-sourced.
