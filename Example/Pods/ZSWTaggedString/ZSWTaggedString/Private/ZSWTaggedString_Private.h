//
//  ZSWTaggedString_Private.h
//  Pods
//
//  Created by Zachary West on 12/12/15.
//
//

NS_ASSUME_NONNULL_BEGIN

/*!
 * @private
 *
 * This and all other 'private' methods work around a compiler bug where
 * we cannot force private headers into Swift files included in the framework.
 * Using any API in here is not supported, and you really should not touch it.
 */

@interface ZSWTaggedStringOptions()
+ (ZSWTaggedStringOptions *)_private_defaultOptionsNoCopy;

- (void)_private_setWrapper:(nullable ZSWTaggedStringAttribute *)attribute forTagName:(NSString *)tagName;

@property (nullable, nonatomic) ZSWTaggedStringAttribute *_private_unknownTagWrapper;
@property (nonatomic) NSDictionary<NSString *, ZSWTaggedStringAttribute *> *_private_tagToAttributesMap;
- (void)_private_updateAttributedString:(NSMutableAttributedString *)string
                        updatedWithTags:(NSArray *)tags;
@end

NS_ASSUME_NONNULL_END
