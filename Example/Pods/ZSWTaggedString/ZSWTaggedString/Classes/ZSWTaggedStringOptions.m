//
//  ZSWTaggedStringOptions.m
//  Pods
//
//  Created by Zachary West on 2015-02-21.
//
//

#import "ZSWTaggedStringOptions.h"
#import "ZSWStringParser.h"
#import "ZSWStringParserTag.h"

@implementation ZSWTaggedStringOptions

static ZSWTaggedStringOptions *ZSWStringParserDefaultOptions;

+ (ZSWTaggedStringOptions *)defaultOptions {
    return [[self defaultOptionsNoCopy] copy];
}

+ (ZSWTaggedStringOptions *)defaultOptionsNoCopy {
    ZSWTaggedStringOptions *options;
    
    @synchronized (self) {
        if (!ZSWStringParserDefaultOptions) {
            ZSWStringParserDefaultOptions = [ZSWTaggedStringOptions options];
        }
        
        options = ZSWStringParserDefaultOptions;
    }
    
    return options;
}

+ (void)registerDefaultOptions:(ZSWTaggedStringOptions *)options {
    @synchronized(self) {
        ZSWStringParserDefaultOptions = [options copy];
    }
}

- (void)commonInit {
    
}

+ (ZSWTaggedStringOptions *)options {
    return [[[self class] alloc] init];
}

+ (ZSWTaggedStringOptions *)optionsWithBaseAttributes:(NSDictionary *)attributes {
    ZSWTaggedStringOptions *options = [[[self class] alloc] initWithBaseAttributes:attributes];
    return options;
}

- (instancetype)init {
    return [self initWithBaseAttributes:nil];
}

- (instancetype)initWithBaseAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        [self commonInit];
        
        self.baseAttributes = attributes ?: [NSDictionary dictionary];
        self.tagToAttributesMap = [NSDictionary dictionary];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        [self commonInit];
        
        self->_baseAttributes = [decoder decodeObjectOfClass:[NSDictionary class]
                                                      forKey:ZSWSelector(baseAttributes)];
        self->_tagToAttributesMap = [decoder decodeObjectOfClass:[NSDictionary class]
                                                          forKey:ZSWSelector(tagToAttributesMap)];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.baseAttributes forKey:ZSWSelector(baseAttributes)];
    [coder encodeObject:self.tagToAttributesMap forKey:ZSWSelector(tagToAttributesMap)];
}

- (id)copyWithZone:(NSZone *)zone {
    ZSWTaggedStringOptions *options = [[[self class] allocWithZone:zone] init];
    options->_baseAttributes = self->_baseAttributes;
    options->_tagToAttributesMap = self->_tagToAttributesMap;
    return options;
}

- (BOOL)isEqual:(ZSWTaggedStringOptions *)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (![object.baseAttributes isEqualToDictionary:self.baseAttributes]) {
        return NO;
    }
    
    if (![object.tagToAttributesMap isEqualToDictionary:self.tagToAttributesMap]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return self.baseAttributes.hash + self.tagToAttributesMap.hash;
}

#pragma mark -

- (void)setTagValue:(NSObject<NSCopying> *)tagValue forTagName:(NSString *)tagName {
    NSMutableDictionary *mutableMap = [self.tagToAttributesMap mutableCopy];
    mutableMap[tagName.lowercaseString] = [tagValue copy];
    self.tagToAttributesMap = mutableMap;
}

- (void)setAttributes:(NSDictionary *)attributes forTagName:(NSString *)tagName {
    NSParameterAssert(tagName.length > 0);
    [self setTagValue:attributes forTagName:tagName];
}

- (void)setDynamicAttributes:(ZSWDynamicAttributes)dynamicAttributes forTagName:(NSString *)tagName {
    NSParameterAssert(tagName != nil);
    [self setTagValue:dynamicAttributes forTagName:tagName];
}

#pragma mark - Internal/updating
- (void)updateAttributedString:(NSMutableAttributedString *)string
               updatedWithTags:(NSArray *)tags {
    NSParameterAssert([string isKindOfClass:[NSMutableAttributedString class]]);
    
    [string setAttributes:self.baseAttributes range:NSMakeRange(0, string.length)];
    
    for (ZSWStringParserTag *tag in tags) {
        id tagValue = self.tagToAttributesMap[tag.tagName.lowercaseString];
        NSDictionary *attributes;
        
        if ([tagValue isKindOfClass:[NSDictionary class]]) {
            attributes = tagValue;
        } else if (tagValue /* is a block */) {
            NSDictionary *existingAttributes = [string attributesAtIndex:tag.location effectiveRange:NULL];
            
            ZSWDynamicAttributes dynamicAttributes = tagValue;
            attributes = dynamicAttributes(tag.tagName, tag.tagAttributes, existingAttributes);
        } else if (self.unknownTagDynamicAttributes) {
            NSDictionary *existingAttributes = [string attributesAtIndex:tag.location effectiveRange:NULL];
            
            attributes = self.unknownTagDynamicAttributes(tag.tagName, tag.tagAttributes, existingAttributes);
        }
        
        if (attributes) {
            [string addAttributes:attributes range:tag.tagRange];
        }
    }
}

@end
