# ZSWTappableLabel

<!--[![CI Status](http://img.shields.io/travis/zacwest/ZSWTappableLabel.svg?style=flat)](https://travis-ci.org/zacwest/ZSWTappableLabel)-->
[![Version](https://img.shields.io/cocoapods/v/ZSWTappableLabel.svg?style=flat)](http://cocoapods.org/pods/ZSWTappableLabel)
[![License](https://img.shields.io/cocoapods/l/ZSWTappableLabel.svg?style=flat)](http://cocoapods.org/pods/ZSWTappableLabel)
[![Platform](https://img.shields.io/cocoapods/p/ZSWTappableLabel.svg?style=flat)](http://cocoapods.org/pods/ZSWTappableLabel)

ZSWTappableLabel is a `UILabel` subclass powered by NSAttributedStrings which allows you to tap or long-press on certain regions, with optional highlight behavior. It does not draw text itself and executes a minimal amount of code unless the user is interacting with a tappable region.

## A basic, tappable link

Let's create a string that's entirely tappable and shown with an underline:

```swift
let string = NSLocalizedString("Privacy Policy", comment: "")
let attributes: [String: AnyObject] = [
  ZSWTappableLabelTappableRegionAttributeName: true,
  ZSWTappableLabelHighlightedBackgroundAttributeName: UIColor.lightGrayColor(),
  ZSWTappableLabelHighlightedForegroundAttributeName: UIColor.whiteColor(),
  NSForegroundColorAttributeName: UIColor.blueColor(),
  NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,

  // You could use NSLinkAttributeName, but this forces foreground color
  "URL": NSURL(string: "http://imgur.com/gallery/VgXCk")!
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

  // You could use NSLinkAttributeName, but this forces foreground color
  @"URL": [NSURL URLWithString:@"http://imgur.com/gallery/VgXCk"],
};

label.attributedText = [[NSAttributedString alloc] initWithString:s attributes:a];
```

This results in a label which renders like:

> [Privacy Policy](https://github.com/zacwest/zswtappablelabel)

Setting your controller as the `tapDelegate` of the label results in the following method call when tapped:

```
func tappableLabel(tappableLabel: ZSWTappableLabel, tappedAtIndex idx: Int, withAttributes attributes: [String : AnyObject]) {
  if let url = attributes["URL"] as? NSURL {
    UIApplication.sharedApplication().openURL(url)
  }
}
```

```objective-c
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary *)attributes {
  [[UIApplication sharedApplication] openURL:attributes[@"URL"]];
}
```

## Long-presses

You may optionally support long-presses by setting a `longPressDelegate` on the label. This behaves very similarly to the `tapDelegate`:

```swift
func tappableLabel(tappableLabel: ZSWTappableLabel, longPressedAtIndex idx: Int, withAttributes attributes: [String : AnyObject]) {
  guard let URL = attributes["URL"] as? NSURL else {
    return
  }
    
  let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
  presentViewController(activityController, animated: true, completion: nil)
}
```

```objectivec
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel 
   longPressedAtIndex:(NSInteger)idx 
       withAttributes:(NSDictionary<NSString *,id> *)attributes {
  NSURL *URL = attributes[URLAttributeName];
  if ([URL isKindOfClass:[NSURL class]]) {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[ URL ] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
  }
}
```

You can configure the `longPressDuration` for how long until a long-press is recognized. This defaults to 0.5 seconds.

## Data detectors

Let's use `NSDataDetector` to find the substrings in a given string that we might want to turn into links:

```swift
let string = "check google.com or call 415-555-5555? how about friday at 5pm?"
let range = NSRange(location: 0, length: (string as NSString).length)

let detector = try! NSDataDetector(types: NSTextCheckingAllSystemTypes)
let attributedString = NSMutableAttributedString(string: string, attributes: nil)

detector.enumerateMatchesInString(string, options: [], range: range) { (result, flags, _) in
  guard let result = result else { return }
  var attributes = [String: AnyObject]()
  attributes[ZSWTappableLabelTappableRegionAttributeName] = true
  attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = UIColor.lightGrayColor()
  attributes[ZSWTappableLabelHighlightedForegroundAttributeName] = UIColor.whiteColor()
  attributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
  attributes["NSTextCheckingResult"] = result
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
func tappableLabel(tappableLabel: ZSWTappableLabel, tappedAtIndex idx: Int, withAttributes attributes: [String : AnyObject]) {
  if let result = attributes["NSTextCheckingResult"] as? NSTextCheckingResult {
    switch result.resultType {
    case [.Address]:
      print("Address components: \(result.addressComponents)")                
    case [.PhoneNumber]:
      print("Phone number: \(result.phoneNumber)")
    case [.Date]:
      print("Date: \(result.date)")
    case [.Link]:
      print("Link: \(result.URL)")
    default:
      break
    }
  }
}
```

```objective-c
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary *)attributes {
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
options["link"] = .Dynamic({ tagName, tagAttributes, stringAttributes in
  guard let type = tagAttributes["type"] as? String else {
    return [String: AnyObject]()
  }
  
  var foundURL: NSURL?
  
  switch type {
  case "privacy":
    foundURL = NSURL(string: "http://google.com/search?q=privacy")!
  case "tos":
    foundURL = NSURL(string: "http://google.com/search?q=tos")!
  default:
    break
  }
  
  guard let URL = foundURL else {
    return [String: AnyObject]()
  }
  
  return [
    ZSWTappableLabelTappableRegionAttributeName: true,
    ZSWTappableLabelHighlightedBackgroundAttributeName: UIColor.lightGrayColor(),
    ZSWTappableLabelHighlightedForegroundAttributeName: UIColor.whiteColor(),
    NSForegroundColorAttributeName: UIColor.blueColor(),
    NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
    "URL": URL
  ]
})

let string = NSLocalizedString("View our <link type='privacy'>Privacy Policy</link> or <link type='tos'>Terms of Service</link>", comment: "")
label.attributedText = try? ZSWTaggedString(string: string).attributedStringWithOptions(options)
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

## VoiceOver

ZSWTappableLabel is an accessibility container, which exposes the substrings in your attributed string as distinct elements. For example, the above string breaks down into:

1. `View our` (static text)
1. `Privacy Policy` (link)
1. ` or ` (static text)
1. `Terms of Service` (link)

When you set a `longPressDelegate`, an additional action on links is added to perform the long-press gesture. You should configure the `longPressAccessibilityActionName` to adjust what is read to users.

## Interaction with gesture recognizers

ZSWTappableLabel uses gesture recognizers internally and works well with other gesture recognizers:

- If there are no tappable regions, internal gesture recognizers are disabled.
- If a touch occurs within a tappable region, all other gesture recognizers are failed if the label is interested in them.
- If a touch occurs outside a tappable region, internal gesture recognizers fail themselves.

For example, if you place a UITapGestureRecognizer on the label, it will only fire when the user does not interact with a tappable region.

## Installation

ZSWTappableLabel is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "ZSWTappableLabel", "~> 1.3"
```

## License

ZSWTappableLabel is available under the [MIT license](https://github.com/zacwest/ZSWTappableLabel/blob/master/LICENSE). This library was created while working on [Free](https://ffrree.com) who allowed this to be open-sourced.
