//
//  ZSWStringParserTag.h
//  Pods
//
//  Created by Zachary West on 2015-02-21.
//
//

/*!
 * @private
 */

#import <Foundation/Foundation.h>

@interface ZSWStringParserTag : NSObject

- (instancetype)initWithTagName:(NSString *)tagName
                  startLocation:(NSInteger)location;
@property (nonatomic, readonly) NSString *tagName;
@property (nonatomic, readonly) NSInteger location;

- (BOOL)isEndingTag;
- (BOOL)isEndedByTag:(ZSWStringParserTag *)tag;
- (void)updateWithTag:(ZSWStringParserTag *)tag;

- (void)addRawTagAttributes:(NSString *)tagAttributes;
- (NSDictionary *)tagAttributes;

- (NSRange)tagRange;

@end
