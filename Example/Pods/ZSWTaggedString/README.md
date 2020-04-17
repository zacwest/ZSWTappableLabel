# ZSWTaggedString

[![CI Status](https://img.shields.io/circleci/project/zacwest/ZSWTaggedString.svg?style=flat)](https://circleci.com/gh/zacwest/ZSWTaggedString)
[![Version](https://img.shields.io/cocoapods/v/ZSWTaggedString.svg?style=flat)](http://cocoapods.org/pods/ZSWTaggedString)
[![License](https://img.shields.io/cocoapods/l/ZSWTaggedString.svg?style=flat)](http://cocoapods.org/pods/ZSWTaggedString)
[![Platform](https://img.shields.io/cocoapods/p/ZSWTaggedString.svg?style=flat)](http://cocoapods.org/pods/ZSWTaggedString)

ZSWTaggedString converts a `String`/`NSString` marked-up with tags into an  `NSAttributedString`. Tags are similar to HTML except you define what each tag represents.

The goal of this library is to separate presentation from string generation while making it easier to create attributed strings. This way you can decorate strings without concatenating or using hard-to-localize substring searches.

The most common example is applying a style change to part of a string. Let's format a string like "bowties are **cool**":

```swift
let localizedString = NSLocalizedString("bowties are <b>cool</b>", comment: "");
let taggedString = ZSWTaggedString(string: localizedString)

let options = ZSWTaggedStringOptions()

options["b"] = .static([
    .font: UIFont.boldSystemFont(ofSize: 18.0)
])

let attributedString = try! taggedString.attributedString(with: options)
print(attributedString)
```

```objective-c
NSString *localizedString = NSLocalizedString(@"bowties are <b>cool</b>", nil);
ZSWTaggedString *taggedString = [ZSWTaggedString stringWithString:localizedString];

ZSWTaggedStringOptions *options = [ZSWTaggedStringOptions options];
[options setAttributes:@{
    NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]
          } forTagName:@"b"];

NSLog(@"%@", [taggedString attributedStringWithOptions:options]);
```

This produces an attributed string where the "cool" substring is bold, and the rest undefined:

```objective-c
bowties are {
}cool{
    NSFont = "<UICTFont: …> …; font-weight: bold; …; font-size: 18.00pt";
}
```

## Dynamic attributes

You can apply style based on metadata included in the string. Let's italicize a substring while changing the color of a story based on its type:

```swift
let story1 = Story(type: .One, name: "on<e")
let story2 = Story(type: .Two, name: "tw<o")

func storyWrap(_ story: Story) -> String {
    // You should separate data-level tags from the localized strings
    // so you can iterate on their definition without the .strings changing
    // Ideally you'd place this on the Story class itself.
    return String(format: "<story type='%d'>%@</story>",
        story.type.rawValue, ZSWEscapedStringForString(story.name))
}

let format = NSLocalizedString("Pick: %@ <i>or</i> %@", comment: "On the story, ...");
let string = ZSWTaggedString(format: format, storyWrap(story1), storyWrap(story2))

let options = ZSWTaggedStringOptions()

// Base attributes apply to the whole string, before any tag attributes.
options.baseAttributes = [
    .font: UIFont.systemFont(ofSize: 14.0),
    .foregroundColor: UIColor.gray
]

// Normal attributes just add their attributes to the attributed string.
options["i"] = .static([
    .font: UIFont.italicSystemFont(ofSize: 14.0)
])

// Dynamic attributes give you an opportunity to decide what to do for each tag
options["story"] = .dynamic({ tagName, tagAttributes, existingAttributes in
    var attributes = [NSAttributedString.Key: AnyObject]()
    
    guard let typeString = tagAttributes["type"] as? String,
        let type = Story.StoryType(rawValue: typeString) else {
            return attributes
    }
    
    switch type {
    case .One:
        attributes[.foregroundColor] = UIColor.red
    case .Two:
        attributes[.foregroundColor] = UIColor.orange
    }
    
    return attributes
})
```

```objective-c
Story *story1 = …, *story2 = …;

NSString *(^sWrap)(Story *) = ^(Story *story) {
    // You should separate data-level tags from the localized strings
    // so you can iterate on their definition without the .strings changing
    // Ideally you'd place this on the Story class itself.
    return [NSString stringWithFormat:@"<story type='%@'>%@</story>",
            @(story.type), ZSWEscapedStringForString(story.name)];
};

NSString *fmt = NSLocalizedString(@"Pick: %@ <i>or</i> %@", @"On the story, ...");
ZSWTaggedString *string = [ZSWTaggedString stringWithFormat:fmt,
                           sWrap(story1), sWrap(story2)];

ZSWTaggedStringOptions *options = [ZSWTaggedStringOptions options];

// Base attributes apply to the whole string, before any tag attributes.
[options setBaseAttributes:@{
    NSFontAttributeName: [UIFont systemFontOfSize:14.0],
    NSForegroundColorAttributeName: [UIColor grayColor]
 }];

// Normal attributes just add their attributes to the attributed string.
[options setAttributes:@{
    NSFontAttributeName: [UIFont italicSystemFontOfSize:14.0]
          } forTagName:@"i"];

// Dynamic attributes give you an opportunity to decide what to do for each tag
[options setDynamicAttributes:^(NSString *tagName,
                                NSDictionary *tagAttributes,
                                NSDictionary *existingStringAttributes) {
    switch ((StoryType)[tagAttributes[@"type"] integerValue]) {
        case StoryTypeOne:
            return @{ NSForegroundColorAttributeName: [UIColor redColor] };
        case StoryTypeTwo:
            return @{ NSForegroundColorAttributeName: [UIColor orangeColor] };
    }
    return @{ NSForegroundColorAttributeName: [UIColor blueColor] };
} forTagName:@"story"];
```

Your localizer now sees a more reasonable localized string:

```json
	/* On the story, ... */
	"Pick: %@ <i>or</i> %@" = "Pick: %1$@ <i>or</i> %2$@";
```

And you don't have to resort to using `.rangeOfString()` to format any of the substrings, which is very difficult to accomplish with what we desired above.

There are two types of dynamic attributes you can use: a tag-specific one like above, or the options-global `unknownTagAttributes` (`unknownTagDynamicAttributes` in Objective-C) which is invoked when an undefined tag is found. Both have three parameters:

1. `tagName` The name of the tag, e.g. `story` above.
2. `tagAttributes` The attributes of the tag, e.g. `["type": "1"]` like above.
3. `existingStringAttributes` The string attributes that exist already, e.g. `[NSForegroundColorAttributeName: UIColor.redColor()]`

You can use the `existingStringAttributes` to handle well-established keys. For example, let's make the `<b>`, `<i>`, and `<u>` tags automatically:

```swift
let options = ZSWTaggedStringOptions()

options.baseAttributes = [
    .font: UIFont.systemFont(ofSize: 12.0)
]

options.unknownTagAttributes = .dynamic({ tagName, tagAttributes, existingAttributes in
    var attributes = [NSAttributedString.Key: Any]()
    
    if let font = existingAttributes[.font] as? UIFont {
        switch tagName {
        case "b":
            attributes[.font] = UIFont.boldSystemFont(ofSize: font.pointSize)
        case "i":
            attributes[.font] = UIFont.italicSystemFont(ofSize: font.pointSize)
        default:
            break
        }
    }
    
    if tagName == "u" {
        attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
    }
    
    return attributes
})
```

```objective-c
ZSWTaggedStringOptions *options = [ZSWTaggedStringOptions options];
[options setBaseAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12.0] }];

[options setUnknownTagDynamicAttributes:^(NSString *tagName,
                                          NSDictionary *tagAttributes,
                                          NSDictionary *existingStringAttributes) {
    BOOL isBold = [tagName isEqualToString:@"b"];
    BOOL isItalic = [tagName isEqualToString:@"i"];
    BOOL isUnderline = [tagName isEqualToString:@"u"];
    UIFont *font = existingStringAttributes[NSFontAttributeName];

    if ((isBold || isItalic) && font) {
        if (isBold) {
            return @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:font.pointSize] };
        } else if (isItalic) {
            return @{ NSFontAttributeName: [UIFont italicSystemFontOfSize:font.pointSize] };
        }
    } else if (isUnderline) {
        return @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) };
    }
    
    return @{};
}];
```

The library does not provide this functionality by default because custom or inexplicit fonts and dynamic type make this behavior unpredictable. You can use `ZSWTaggedStringOptions.registerDefaultOptions()` to keep a global default set of options with something like the above.

## Fast stripped strings

Stripping tags allows you to create a `String` for fast height calculations (assuming no font changes), statistics gathering, etc., without the overhead of tags. You can accomplished this by using the `.string()` method on a `ZSWTaggedString` instead of the `.attributedString()` methods.

## Error handling

Invalid strings such as non-ending tags (`<a>taco!`) or strings where you do not escape user input (see [Gotchas](#gotchas)) are considered errors by the programmer.

For Swift consumers, all of the methods throw when you provide invalid input.

For Objective-C consumers, there are optional `NSError`-returning methods, and all of the methods return `nil` in the error case.

## Gotchas

If any of your composed strings contain a `<` character without being in a tag, you _must_ wrap the string with `ZSWEscapedStringForString()`. In practice, user-generated content where this is important is rare, but you must handle it.

## Installation

ZSWTaggedString is available through [CocoaPods](http://cocoapods.org). Add the following line to your Podfile:

```ruby
pod "ZSWTaggedString", "~> 4.2"
pod "ZSWTaggedString/Swift", "~> 4.2" # Optional, for Swift support
```

## License

ZSWTaggedString is available under the [MIT license](https://github.com/zacwest/ZSWTaggedString/blob/master/LICENSE). If you are contributing via pull request, please include an appropriate test for the bug you are fixing or feature you are adding.
