//
//  ZSWTaggedString.h
//  Pods
//
//  Created by Zachary West on 2015-02-21.
//
//

#import <Foundation/Foundation.h>
#import "ZSWTaggedStringOptions.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ZSWTaggedStringErrorDomain;
typedef NS_ENUM(NSInteger, ZSWTaggedStringErrorCode) {
    ZSWTaggedStringErrorCodeInvalidTags = 100,
};

/*!
 * @brief Escape a string that does not feature tags
 *
 * For example, user-generated input or untrustworthy database contents.
 * Not needed if you're just localizing strings.
 */
extern NSString *ZSWEscapedStringForString(NSString *unescapedString);

/*!
 * @class ZSWTaggedString
 
 * @warning If you create a string by concatenating those that might include '<'
 * not as tags, you \b MUST run these substrings through
 * \ref ZSWEscapedStringForString or parsing may produce undefined results,
 * including invalid output or assertions firing.
 *
 * See the README file for detailed usage information:
 *
 * https://github.com/zacwest/ZSWStringParser
 */
@interface ZSWTaggedString : NSObject <NSCopying, NSSecureCoding>

/*!
 * @brief Create a tagged string from a format
 *
 * See the \ref ZSWTaggedString documentation for information on tagging format.
 *
 * Very little computation is done in this method with the intention that
 * returning it from a model layer is as quick as possible. The methods which
 * generate \ref NSString or \ref NSAttributedString versions take up the
 * chunk of the work.
 */
+ (instancetype)stringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_SWIFT_UNAVAILABLE("init(format:) is available in the Swift subpod");

/*!
 * @brief Create an unparsed string from a tagged string
 *
 * See the \ref ZSWTaggedString documentation for information on tagging format.
 *
 * Like \ref -stringWithFormat:, very little computation is done in this method.
 */
+ (instancetype)stringWithString:(NSString *)string NS_SWIFT_UNAVAILABLE("Use init(string:)");
- (instancetype)initWithString:(NSString *)string;

@property (nonatomic, copy) NSString *underlyingString;

/*!
 * @brief Attributed version of an unparsed string
 *
 * If you have registered default options via
 * \ref +[ZSWTaggedStringOptions registerDefaultOptions:] this will use the
 * default options to generate an attributed string.
 *
 * If you have not registered default attributes, this will use a set of options
 * without any attributes, which is more computationally expensive than
 * \ref -string and produces similar results.
 *
 * @return Parsed version of the unparsed string
 */
- (nullable NSAttributedString *)attributedString NS_SWIFT_UNAVAILABLE("Use the throwing version");
- (nullable NSAttributedString *)attributedStringWithError:(NSError **)error;

/*!
 * @brief Attributed version of of an unparsed string
 *
 * @param options The options to use. For defailts, use the options-less method.
 *
 * For available options, see \ref ZSWTaggedStringOptions
 *
 * @return Parsed version of the unparsed string
 */
- (nullable NSAttributedString *)attributedStringWithOptions:(ZSWTaggedStringOptions *)options NS_SWIFT_UNAVAILABLE("Use the throwing version");
- (nullable NSAttributedString *)attributedStringWithOptions:(ZSWTaggedStringOptions *)options error:(NSError **)error;

/*!
 * @brief Stripped string
 *
 * See \ref -stringWithOptions:
 *
 * This uses the default options like \ref -attributedString.
 *
 * @return Stripped version of the unparsed string
 */
- (nullable NSString *)string NS_SWIFT_UNAVAILABLE("Use the throwing version");
- (nullable NSString *)stringWithError:(NSError **)error;

/*!
 * @brief Stripped string with options
 *
 * This strips the tags from the unparsed string. Roughly equivalent to:
 *
 *      [[taggedString attributedString] string]
 *
 * Some performance optimizations may take place, and so this method is faster
 * than creating an attributed string.
 *
 * This can be useful in situations where, for example, you may have persisted
 * tagged strings to disk and wish to quickly calculate non-attributed
 * statistics or metadata.
 *
 * This method allows you to pass in a set of options for e.g. allowing it to
 * return an empty string. For available options, see \ref ZSWTaggedStringOptions
 *
 * @return Stripped version of the unparsed string
 */
- (nullable NSString *)stringWithOptions:(ZSWTaggedStringOptions *)options NS_SWIFT_UNAVAILABLE("Use the throwing version");
- (nullable NSString *)stringWithOptions:(ZSWTaggedStringOptions *)options error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
