//
//  ZSWTappableLabel.h
//  ZSWTappableLabel
//
//  Created by Zachary West on 3/23/15.
//  Copyright (c) 2015 Zachary West. All rights reserved.
//
//  MIT License
//  https://github.com/zacwest/ZSWTappableLabel
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Attributes you include in strings

/*!
 * @brief Highlight the background color behind when selected
 *
 * Value is a UIColor. When a touch event occurs within this range, the attribute
 * \a NSBackgroundColorAttributeName is applied to the tappable region.
 */
extern NSAttributedStringKey const ZSWTappableLabelHighlightedBackgroundAttributeName NS_SWIFT_NAME(tappableHighlightedBackgroundColor);
/*!
 * @brief Highlight the text color when selected
 *
 * Value is a UIColor. When a touch event occurs within this range, the attribute
 * \a NSForegroundColorAttributeName is applied to the tappable region.
 */
extern NSAttributedStringKey const ZSWTappableLabelHighlightedForegroundAttributeName NS_SWIFT_NAME(tappableHighlightedForegroundColor);

/*!
 * @brief A highlighted region - enables interaction
 *
 * Value is an NSNumber (BOOL). If the location of a touch has this attribute,
 * the \ref -[ZSWTappableLabel tapDelegate] will be invoked.
 */
extern NSAttributedStringKey const ZSWTappableLabelTappableRegionAttributeName NS_SWIFT_NAME(tappableRegion);

#pragma mark - Tap delegate

@class ZSWTappableLabel;
/*!
 * @brief The tap delegate of the label
 *
 * You set your delegate using \ref -[ZSWTappableLabel setTapDelegate:]
 */
@protocol ZSWTappableLabelTapDelegate
/*!
 * @brief A tap was completed
 *
 * @param tappableLabel The label
 * @param idx The string index closest to the touch
 * @param attributes The attributes from the attributed string at the given index
 *
 * This method is only invoked if \ref ZSWTappableLabelTappableRegionAttributeName
 * is specified in the attributes under the touch.
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
 * This method is only invoked if \ref ZSWTappableLabelTappableRegionAttributeName
 * is specified in the attributes under the touch.
 *
 * If the user presses and holds at one spot for at least
 * \ref longPressDuration seconds, this delegate method will be invoked.
 *
 * It may also be invoked by users with accessibility enabled. You should set
 * \ref longPressAccessibilityActionName to give your users
 * a better description of what this does.
 */
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
   longPressedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes;
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
 * @brief Long press duration
 *
 * How long, in seconds, the user must long press without lifting before
 * the touch should be recognized as a long press.
 *
 * If you do not set a \ref longPressDelegate, a long press does not occur.
 *
 * This defaults to 0.5 seconds.
 */
@property (nonatomic) NSTimeInterval longPressDuration;

/*!
 * @brief Accessibility label for long press
 *
 * Your users will be read this localized string when they choose to
 * dig into the custom actions a link has.
 *
 * If you do not set a \ref longPressDelegate, this action is not included.
 *
 * This defaults to 'Open Menu'.
 */
@property (null_resettable, nonatomic, copy) NSString *longPressAccessibilityActionName;

@end

NS_ASSUME_NONNULL_END
