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

#pragma mark - Attributes you include in strings

/*!
 * @brief Highlight the background color behind when selected
 *
 * Value is a UIColor. When a touch event occurs within this range, the attribute
 * \a NSBackgroundColorAttributeName is applied to the tappable region.
 */
extern NSString *const ZSWTappableLabelHighlightedBackgroundAttributeName;
/*!
 * @brief Highlight the text color when selected
 *
 * Value is a UIColor. When a touch event occurs within this range, the attribute
 * \a NSForegroundColorAttributeName is applied to the tappable region.
 */
extern NSString *const ZSWTappableLabelHighlightedForegroundAttributeName;

/*!
 * @brief A highlighted region - enables interaction
 *
 * Value is an NSNumber (BOOL). If the location of a touch has this attribute,
 * the \ref -[ZSWTappableLabel tapDelegate] will be invoked.
 */
extern NSString *const ZSWTappableLabelTappableRegionAttributeName;

#pragma mark - Tap delegate

@class ZSWTappableLabel;
/*!
 * @brief The tap delegate of the label
 *
 * You set your delegate using \ref -[ZSWTappableLabel setTapDelegate:]
 */
@protocol ZSWTappableLabelTapDelegate <NSObject>
/*!
 * @brief A tap was completed
 *
 * @param tappableLabel
 * @param idx The string index closest to the touch
 * @param attributes The attributes from the attributed string at the given index
 *
 * This method is only invoked if \ref ZSWTappableLabelTappableRegionAttributeName
 * is specified in the attributes under the touch.
 */
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary *)attributes;
@end

#pragma mark -

@interface ZSWTappableLabel : UILabel

@property (nonatomic, weak) id<ZSWTappableLabelTapDelegate> tapDelegate;

@end
