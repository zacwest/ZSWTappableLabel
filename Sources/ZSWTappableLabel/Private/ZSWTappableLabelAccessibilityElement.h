//
//  ZSWTappableLabelAccessibilityElement.h
//  ZSWTappableLabel
//
//  Copyright (c) 2020 Zachary West. All rights reserved.
//
//  MIT License
//  https://github.com/zacwest/ZSWTappableLabel
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZSWTappableLabelAccessibilityElement : UIAccessibilityElement
@property (nullable, nonatomic) BOOL (^activateBlock)(void);
@end

NS_ASSUME_NONNULL_END
