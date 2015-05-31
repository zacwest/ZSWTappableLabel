# ZSWTappableLabel

<!--[![CI Status](http://img.shields.io/travis/zacwest/ZSWTappableLabel.svg?style=flat)](https://travis-ci.org/zacwest/ZSWTappableLabel)-->
[![Version](https://img.shields.io/cocoapods/v/ZSWTappableLabel.svg?style=flat)](http://cocoapods.org/pods/ZSWTappableLabel)
[![License](https://img.shields.io/cocoapods/l/ZSWTappableLabel.svg?style=flat)](http://cocoapods.org/pods/ZSWTappableLabel)
[![Platform](https://img.shields.io/cocoapods/p/ZSWTappableLabel.svg?style=flat)](http://cocoapods.org/pods/ZSWTappableLabel)

ZSWTappableLabel is a `UILabel` subclass powered by NSAttributedStrings which allows you to tap on certain regions, with optional highlight behavior. It does not draw text itself and executes a minimal amount of code unless the user is interacting with a tappable region.

## A basic, tappable link

Let's create a string that's entirely tappable and shown with an underline:

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

```objective-c
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary *)attributes {
  [[UIApplication sharedApplication] openURL:attributes[@"URL"]];
}
```

## Substring linking

For substring linking, I suggest you use [ZSWTaggedString](https://github.com/zacwest/zswtaggedstring) which creates these attributed strings painlessly and localizably. Let's create a more advanced 'privacy policy' link using this library:

> View our [Privacy Policy](https://github.com/zacwest/zswtappablelabel) or [Terms of Service](https://github.com/zacwest/zswtappablelabel)

You can create such a string using a simple ZSWTaggedString:

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

## Interaction with gesture recognizers

ZSWTappableLabel uses gesture recognizers internally and works well with other gesture recognizers:

- If there are no tappable regions, internal gesture recognizers are disabled.
- If a touch occurs within a tappable region, all other gesture recognizers are failed if the label is interested in them.
- If a touch occurs outside a tappable region, internal gesture recognizers fail themselves.

For example, if you place a UITapGestureRecognizer on the label, it will only fire when the user does not interact with a tappable region.

## Installation

ZSWTappableLabel is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "ZSWTappableLabel", "~> 1.1"
```

## License

ZSWTappableLabel is available under the [MIT license](https://github.com/zacwest/ZSWTappableLabel/blob/master/LICENSE). This library was created while working on [Free](https://ffrree.com) who allowed this to be open-sourced.
