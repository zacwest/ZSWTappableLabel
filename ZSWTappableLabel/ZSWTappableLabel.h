//
//  ZSWTappableLabel.h
//  ZSWTappableLabel
//
//  Created by Zachary West on 3/23/15.
//  Copyright (c) 2019 Zachary West. All rights reserved.
//
//  MIT License
//  https://github.com/zacwest/ZSWTappableLabel
//

#import <UIKit/UIKit.h>
#import "ZSWTappableLabelTappableRegionInfo.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Attributes you include in strings

/*!
 * @brief Highlight the background color behind when selected
 *
 * Value is a UIColor. When a touch event occurs within this range, the attribute \a NSBackgroundColorAttributeName is
 * applied to the tappable region.
 */
extern NSAttributedStringKey const ZSWTappableLabelHighlightedBackgroundAttributeName
    NS_SWIFT_NAME(tappableHighlightedBackgroundColor);

/*!
 * @brief Highlight the text color when selected
 *
 * Value is a UIColor. When a touch event occurs within this range, the attribute \a NSForegroundColorAttributeName is
 * applied to the tappable region.
 */
extern NSAttributedStringKey const ZSWTappableLabelHighlightedForegroundAttributeName
    NS_SWIFT_NAME(tappableHighlightedForegroundColor);

/*!
 * @brief A highlighted region - enables interaction
 *
 * Value is an NSNumber (BOOL). If the location of a touch has this attribute, the \a tapDelegate will be invoked.
 */
extern NSAttributedStringKey const ZSWTappableLabelTappableRegionAttributeName
    NS_SWIFT_NAME(tappableRegion);

#pragma mark - Tap delegate

@class ZSWTappableLabel;

@protocol ZSWTappableLabelTapDelegate
/*!
 * @brief A tap was completed
 *
 * @param tappableLabel The label
 * @param idx The string index closest to the touch
 * @param attributes The attributes from the attributed string at the given index
 *
 * This method is only invoked if \a ZSWTappableLabelTappableRegionAttributeName is specified in the attributes
 * under the touch.
 */
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes;
@end

@protocol ZSWTappableLabelLongPressDelegate
/*!
 * @brief A long press was completed
 *
 * @param tappableLabel The label
 * @param idx The string index closest to the touch
 * @param attributes The attributes from the attributed string at the given index
 *
 * This method is only invoked if \a ZSWTappableLabelTappableRegionAttributeName is specified in the attributes
 * under the touch.
 *
 * If the user presses and holds at one spot for at least \a longPressDuration seconds, this delegate method
 * will be invoked.
 *
 * It may also be invoked by users with accessibility enabled. You should set \a longPressAccessibilityActionName
 * to give your users a better description.
 */
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
   longPressedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes;
@end

@protocol ZSWTappableLabelAccessibilityDelegate
/*!
 * @brief Provide custom actions for a given element
 *
 * @param tappableLabel The label
 * @param characterRange The range of characters represented by an element
 * @param attributes The attributes from the attributed string for the first location of the range
 *
 * Any returned actions will be included after (in the array) a long-press action, if \a longPressDelegate is set.
 *
 * @note Only the attributes for the first character of the string are included since the attributes can vary
 * over the substring.
 *
 * @return The additional elements to include, or empty array to include none
 */
- (NSArray<UIAccessibilityCustomAction *> *)tappableLabel:(ZSWTappableLabel *)tappableLabel
              accessibilityCustomActionsForCharacterRange:(NSRange)characterRange
                                    withAttributesAtStart:(NSDictionary<NSAttributedStringKey, id> *)attributes;
@end

#pragma mark -

@interface ZSWTappableLabel : UILabel

/*!
 * @brief Delegate which handles taps
 */
@property (nullable, nonatomic, weak) IBOutlet id<ZSWTappableLabelTapDelegate> tapDelegate;

/*!
 * @brief Delegate which handles long-presses
 */
@property (nullable, nonatomic, weak) IBOutlet id<ZSWTappableLabelLongPressDelegate> longPressDelegate;

/*!
 * @brief Delegate which handles accessibility
 */
@property (nullable, nonatomic, weak) IBOutlet id<ZSWTappableLabelAccessibilityDelegate> accessibilityDelegate;

/*!
 * @brief Get the tappable region info at a point
 *
 * @param point The point in the label's coordinate space to look for a tappable region
 *
 * This is particularly useful if you need to inspect the label's current regions, for example you are responding
 * to a 3D Touch previewing event and all you know is the point the event is occurring at.
 *
 * It is very important that you convert to the label's coordinate space when asking for this point information.
 * Because of this, a convenience method is available as \a -tappableRegionInfoForPreviewingContext:location:
 *
 * Without the convenience method, for example, from a 3D Touch previewing event you would use:
 *
 * @code
 * label.convert(location, from: previewingContext.sourceView)
 * @endcode
 *
 * in Swift, or in Objective-C:
 *
 * @code
 * [self.label convertPoint:location fromView:previewingContext.sourceView]
 * @endcode
 *
 * @return The region information if a region is at the point, nil otherwise
 *
 * See \a ZSWTappableLabelTappableRegionInfo for the information returned
 */
- (nullable ZSWTappableLabelTappableRegionInfo *)tappableRegionInfoAtPoint:(CGPoint)point;

/*!
 * @brief Convenience method to get tappable region for 3D Touch
 *
 * Since the point/hierarchy management is easy to get confused on, this method is provided to turn a 3D Touch
 * previewing context into a tappable region info.
 *
 * You may also find the \a ZSWTappableLabelTappableRegionInfo convenience method for configuring a preview
 * context to be useful.
 *
 * @return The region information for the preview context if there's a region underneath, nil otherwise
 *
 * See \a ZSWTappableLabelTappableRegionInfo for the information returned
 */
- (nullable ZSWTappableLabelTappableRegionInfo *)
    tappableRegionInfoForPreviewingContext:(id<UIViewControllerPreviewing>)previewingContext location:(CGPoint)location;

/*!
 * @brief Long press duration
 *
 * How long, in seconds, the user must long press without lifting before the touch should be recognized as a long press.
 *
 * If you do not set a \a longPressDelegate, a long press does not occur.
 *
 * This defaults to 0.5 seconds.
 */
@property (nonatomic) NSTimeInterval longPressDuration;

/*!
 * @brief Accessibility label for long press
 *
 * Your users will be read this localized string when they choose to dig into the custom actions a link has.
 *
 * If you do not set a \a longPressDelegate, this action is not included.
 *
 * This defaults to 'Open Menu'.
 */
@property (null_resettable, nonatomic, copy) IBInspectable NSString *longPressAccessibilityActionName;

@end

NS_ASSUME_NONNULL_END
