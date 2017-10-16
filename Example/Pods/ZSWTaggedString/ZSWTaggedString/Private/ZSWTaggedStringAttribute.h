//
//  ZSWTaggedStringAttribute.h
//  Pods
//
//  Created by Zachary West on 12/6/15.
//
//

#import <ZSWTaggedString/ZSWTaggedString.h>

@class ZSWStringParserTag;

@interface ZSWTaggedStringAttribute: NSObject <NSCopying>
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *staticDictionary;
@property (nonatomic, copy) ZSWDynamicAttributes dynamicAttributes;

- (NSDictionary<NSAttributedStringKey, id> *)attributesForTag:(ZSWStringParserTag *)tag forString:(NSAttributedString *)string;
@end
