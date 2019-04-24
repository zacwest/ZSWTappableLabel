//
//  ZSWTappableLabelTappableRegionInfoImpl.h
//  ZSWTappableLabel
//
//  Created by Zac West on 4/23/19.
//

#import <Foundation/Foundation.h>
#import "../ZSWTappableLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZSWTappableLabelTappableRegionInfoImpl : NSObject <ZSWTappableLabelTappableRegionInfo>
- (instancetype)initWithFrame:(CGRect)frame
                   attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes
                containerView:(UIView *)containerView;
@end

NS_ASSUME_NONNULL_END
