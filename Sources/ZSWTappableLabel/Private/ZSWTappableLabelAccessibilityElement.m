//
//  ZSWTappableLabelAccessibilityElement.m
//  ZSWTappableLabel
//
//  Copyright (c) 2020 Zachary West. All rights reserved.
//
//  MIT License
//  https://github.com/zacwest/ZSWTappableLabel
//

#import "ZSWTappableLabelAccessibilityElement.h"

@implementation ZSWTappableLabelAccessibilityElement

- (BOOL)accessibilityActivate
{
    BOOL (^activateBlock)(void) = self.activateBlock;
    if (activateBlock) {
        return activateBlock();
    } else {
        return NO;
    }
}

@end
