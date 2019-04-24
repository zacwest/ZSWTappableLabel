//
//  ZSWTappableLabelTappableRegionInfo_Private.h
//  ZSWTappableLabel
//
//  Created by Zac West on 4/20/19.
//  Copyright (c) 2019 Zachary West. All rights reserved.
//
//  MIT License
//  https://github.com/zacwest/ZSWTappableLabel
//

#import "../ZSWTappableLabelTappableRegionInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZSWTappableLabelTappableRegionInfo(Private)

- (instancetype)initWithFrame:(CGRect)frame
                   attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes
                containerView:(UIView *)containerView;

@end

NS_ASSUME_NONNULL_END
