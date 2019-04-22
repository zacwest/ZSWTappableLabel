# 3.0 (2019-??-??)

- Updates touch handling, improving the long-press experience and adding support for 3D Touch.
- Introduces an accessibility delegate, to provide actions for links within the label.
- Adds the ability to get attributes at a point, particularly for use with 3D Touch.
- Updated examples for Xcode 10.2 and Swift 5 (the pod itself did not need updates).
- Fixes long press delegate call not being invoked unless there was a foreground or background highlight state.
- Fixes not handling `adjustsFontForContentSizeCategory` correctly, where tap handling would not update to the new size.
- Now requires iOS 10 or later, specifically for `-[UIAccessibilityElement accessibilityFrameInContainerSpace]`.

# 2.0 (2017-10-16)

- Updated for Xcode 9 (and Swift 4).

# 1.3.1 (2017-05-12)

- Fixes some cases where the last line in a label, when sized to fit, would not be tappable on iOS 10.

# 1.3 (2015-12-20)

- Long press support: set a longPressDelegate (like tapDelegate) and be notified when the user long-presses.

# 1.2 (2015-12-05)

- Adds annotations for nullability and generics to ease Swift import.
- Fixes a couple Interface Builder issues:
    - Flag the delegate as an IBOutlet so it can be assigned.
    - Fix text being cleared/unset if only set via the IB editor.
- Fixes text alignments other than left set on the label rather than via NSParagraphStyle.
- Fixes VoiceOver element positions when placed inside a UIScrollView.

# 1.1 (2015-05-31)

- VoiceOver support
- Removes `-setText:` unavailability (though you should still use `-setAttributedText:`)

# 1.0 (2015-05-28)

Initial release
