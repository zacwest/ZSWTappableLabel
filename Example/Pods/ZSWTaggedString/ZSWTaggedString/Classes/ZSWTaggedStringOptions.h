//
//  ZSWTaggedStringOptions.h
//  Pods
//
//  Created by Zachary West on 2015-02-21.
//
//

#import <Foundation/Foundation.h>

typedef NSDictionary *(^ZSWDynamicAttributes)(NSString *tagName, NSDictionary *tagAttributes, NSDictionary *existingStringAttributes);

@interface ZSWTaggedStringOptions : NSObject <NSCopying, NSSecureCoding>

/*!
 * @brief Register a set of default options
 *
 * A copy of the options provided is used as the default options. If you wish to make changes after registration,
 * you must re-register.
 */
+ (void)registerDefaultOptions:(ZSWTaggedStringOptions *)options;
+ (ZSWTaggedStringOptions *)defaultOptions;

+ (ZSWTaggedStringOptions *)options;
+ (ZSWTaggedStringOptions *)optionsWithBaseAttributes:(NSDictionary *)attributes;

@property (nonatomic, copy) NSDictionary *baseAttributes;

- (void)setAttributes:(NSDictionary *)attributes forTagName:(NSString *)tagName;
- (void)setDynamicAttributes:(ZSWDynamicAttributes)dynamicAttributes forTagName:(NSString *)tagName;

@property (nonatomic, copy) ZSWDynamicAttributes unknownTagDynamicAttributes;

/*!
 * @brief Should we treat nil as an empty string?
 *
 * Default is NO.
 *
 * When YES, this will return an empty NSString or NSAttributedString
 * (depending on which method you call on ZSWTaggedString) instead of
 * a nil value when you create a ZSWTaggedString with a nil NSString.
 */
@property (nonatomic) BOOL returnEmptyStringForNil;

@end
