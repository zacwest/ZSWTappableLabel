//
//  ZSWTappableLabelTappableRegionInfo.h
//  ZSWTappableLabel
//
//  Created by Zac West on 4/20/19.
//  Copyright (c) 2019 Zachary West. All rights reserved.
//
//  MIT License
//  https://github.com/zacwest/ZSWTappableLabel
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZSWTappableLabelTappableRegionInfo : NSObject

/*!
 * @brief The frame of the tappable region in the label's coordinate space
 *
 * If you are setting this as the sourceRect for the previewingContext of a 3D Touch event
 * you will need to convert it to the sourceView's coordinate space, for example:
 *
 *   previewingContext.sourceRect = previewingContext.sourceView.convert(regionInfo.frame, from: label)
 *
 * in Swift, or in Objective-C:
 *
 *   previewingContext.sourceRect = [previewingContext.sourceView convertRect:regionInfo.frame fromView:self.label];
 *
 * Since this is easy to get wrong, see \a -configurePreviewingContext:
 */
@property (nonatomic, readonly) CGRect frame;

/*!
 * @brief The attributed string attributes at the point
 */
@property (nonatomic, readonly) NSDictionary<NSAttributedStringKey, id> *attributes;

/*!
 * @brief Convenience method for 3D Touch
 *
 * Configures the previewing context with the correct frame information for this tappable region info.
 */
- (void)configurePreviewingContext:(id<UIViewControllerPreviewing>)previewingContext NS_SWIFT_NAME(configure(previewingContext:));

@end

NS_ASSUME_NONNULL_END
