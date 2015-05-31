# ZSWTaggedString

[![CI Status](http://img.shields.io/travis/zacwest/ZSWTaggedString.svg?style=flat)](https://travis-ci.org/zacwest/ZSWTaggedString)
[![Version](https://img.shields.io/cocoapods/v/ZSWTaggedString.svg?style=flat)](http://cocoadocs.org/docsets/ZSWTaggedString)
[![License](https://img.shields.io/cocoapods/l/ZSWTaggedString.svg?style=flat)](http://cocoadocs.org/docsets/ZSWTaggedString)
[![Platform](https://img.shields.io/cocoapods/p/ZSWTaggedString.svg?style=flat)](http://cocoadocs.org/docsets/ZSWTaggedString)

ZSWTaggedString converts an `NSString` marked-up with tags into an  `NSAttributedString`. Tags are similar to HTML except you define what each tag represents.

The goal of this library is to separate presentation from string generation while making it easier to create attributed strings. This way you can decorate strings without concatenating or using hard-to-localize substring searches.

The most common example is applying a style change to part of a string. Let's format a string like "bowties are **cool**":

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

And you don't have to resort to using `-rangeOfString:` to format any of the substrings, which is very difficult to accomplish with what we desired above.

There are two types of dynamic attributes you can use: a tag-specific one like above, or the options-global `unknownTagDynamicAttributes` which is invoked when an undefined tag is found. Both have three parameters:

1. `tagName` The name of the tag, e.g. `story` above.
2. `tagAttributes` The attributes of the tag, e.g. `@{ @"type": @"1" }` like above.
3. `existingStringAttributes` The attributed string attributes that exist already.

You can use the `existingStringAttributes` to handle well-established keys. For example, let's make the `<b>`, `<i>`, and `<u>` tags automatically:

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
    
    return (NSDictionary *)nil;
}];
```

The library does not provide this functionality by default because custom or inexplicit fonts and dynamic type make this behavior unpredictable. You can use `-[ZSWTaggedStringOptions registerDefaultOptions:]` to keep a global default set of options with something like the above.

## Fast stripped strings

Stripping the tags off allows you to produce a flat string for fast height calculations (assuming no font changes), statistics gathering, etc., without needing the overhead of an attributed string. You can accomplished this by using the `-string` method on a `ZSWTaggedString` instead of the `-attributedString` methods.

## Gotchas

If any of your composed strings contain a `<` character without being in a tag, you _must_ wrap the string with `ZSWEscapedStringForString()`. In practice, user-generated content where this is important is rare, but you must handle it.

## Installation

ZSWTaggedString is available through [CocoaPods](http://cocoapods.org). Add the following line to your Podfile:

```ruby
pod "ZSWTaggedString", "~> 1.0"
```

## License

ZSWTaggedString is available under the [MIT license](https://github.com/zacwest/ZSWTaggedString/blob/master/LICENSE). If you are contributing via pull request, please include an appropriate test for the bug you are fixing or feature you are adding.