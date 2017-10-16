//
//  ZSWTaggedStringOptions.h
//  Pods
//
//  Created by Zachary West on 2015-02-21.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary<NSAttributedStringKey, id> * _Nonnull(^ZSWDynamicAttributes)(NSString *_Nonnull tagName, NSDictionary<NSString *, id> *_Nonnull tagAttributes, NSDictionary<NSAttributedStringKey, id> *_Nonnull existingStringAttributes) NS_SWIFT_UNAVAILABLE("Use the enumful setters, which have a better closure wrapper with names");

@interface ZSWTaggedStringOptions : NSObject <NSCopying>

/*!
 * @brief Register a set of default options
 *
 * A copy of the options provided is used as the default options. If you wish to make changes after registration,
 * you must re-register.
 */
+ (void)registerDefaultOptions:(ZSWTaggedStringOptions *)options;
+ (ZSWTaggedStringOptions *)defaultOptions;

+ (ZSWTaggedStringOptions *)options;
+ (ZSWTaggedStringOptions *)optionsWithBaseAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes;
- (instancetype)initWithBaseAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes;

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *baseAttributes;

- (void)setAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes forTagName:(NSString *)tagName NS_SWIFT_UNAVAILABLE("Use the enum-ful replacement. You may need to include the Swift subpod.");
- (void)setDynamicAttributes:(nullable ZSWDynamicAttributes)dynamicAttributes forTagName:(NSString *)tagName NS_SWIFT_UNAVAILABLE("Use the enum-ful replacement. You may need to include the Swift subpod.");

@property (nullable, nonatomic, copy) ZSWDynamicAttributes unknownTagDynamicAttributes NS_SWIFT_UNAVAILABLE("Use the enum-ful replacement. You may need to include the Swift subpod.");

@end

NS_ASSUME_NONNULL_END
