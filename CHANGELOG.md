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
