//
//  ZSWTaggedStringOptions.m
//  Pods
//
//  Created by Zachary West on 2015-02-21.
//
//

#import <ZSWTaggedString/ZSWTaggedStringOptions.h>
#import <ZSWTaggedString/ZSWStringParser.h>
#import <ZSWTaggedString/ZSWStringParserTag.h>

#import <ZSWTaggedString/ZSWTaggedString_Private.h>

@implementation ZSWTaggedStringOptions

static ZSWTaggedStringOptions *ZSWStringParserDefaultOptions;

+ (ZSWTaggedStringOptions *)defaultOptions {
    return [[self _private_defaultOptionsNoCopy] copy];
}

+ (ZSWTaggedStringOptions *)_private_defaultOptionsNoCopy {
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
    return [self initWithBaseAttributes:@{}];
}

- (instancetype)initWithBaseAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        [self commonInit];
        
        self.baseAttributes = attributes ?: [NSDictionary dictionary];
        self._private_tagToAttributesMap = [NSDictionary dictionary];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ZSWTaggedStringOptions *options = [[[self class] allocWithZone:zone] init];
    options->_baseAttributes = self->_baseAttributes;
    options->__private_tagToAttributesMap = self->__private_tagToAttributesMap;
    options->__private_unknownTagWrapper = self->__private_unknownTagWrapper;
    return options;
}

- (BOOL)isEqual:(ZSWTaggedStringOptions *)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (![object.baseAttributes isEqualToDictionary:self.baseAttributes]) {
        return NO;
    }
    
    if (![object._private_tagToAttributesMap isEqualToDictionary:self._private_tagToAttributesMap]) {
        return NO;
    }
    
    if (object._private_unknownTagWrapper != self._private_unknownTagWrapper && ![object._private_unknownTagWrapper isEqual:self._private_unknownTagWrapper]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return self.baseAttributes.hash + self._private_tagToAttributesMap.hash + self._private_unknownTagWrapper.hash;
}

#pragma mark -

- (void)_private_setWrapper:(ZSWTaggedStringAttribute *)attribute forTagName:(NSString *)tagName {
    NSMutableDictionary *mutableMap = [self._private_tagToAttributesMap mutableCopy];
    mutableMap[tagName.lowercaseString] = [attribute copy];
    self._private_tagToAttributesMap = mutableMap;
}

- (void)setAttributes:(NSDictionary<NSAttributedStringKey,id> *)dict forTagName:(NSString *)tagName {
    NSParameterAssert(tagName.length > 0);
    
    ZSWTaggedStringAttribute *attribute = [[ZSWTaggedStringAttribute alloc] init];
    attribute.staticDictionary = dict;
    
    [self _private_setWrapper:attribute forTagName:tagName];
}

- (void)setDynamicAttributes:(ZSWDynamicAttributes)dynamicAttributes forTagName:(NSString *)tagName {
    NSParameterAssert(tagName != nil);
    ZSWTaggedStringAttribute *attribute = [[ZSWTaggedStringAttribute alloc] init];
    attribute.dynamicAttributes = dynamicAttributes;
    [self _private_setWrapper:attribute forTagName:tagName];
}

- (void)setUnknownTagDynamicAttributes:(ZSWDynamicAttributes)unknownTagDynamicAttributes {
    ZSWTaggedStringAttribute *attribute = [[ZSWTaggedStringAttribute alloc] init];
    attribute.dynamicAttributes = unknownTagDynamicAttributes;
    self._private_unknownTagWrapper = attribute;
}

- (ZSWDynamicAttributes)unknownTagDynamicAttributes {
    return self._private_unknownTagWrapper.dynamicAttributes;
}

#pragma mark - Internal/updating
- (void)_private_updateAttributedString:(NSMutableAttributedString *)string
               updatedWithTags:(NSArray *)tags {
    NSParameterAssert([string isKindOfClass:[NSMutableAttributedString class]]);
    
    if (string.length == 0) {
        // For example, a string like '<blah></blah>' has no content, so we can 't
        // adjust what's inside based on tags. All we can do is base attributes.
        // For dynamic attributes below, we may end up calling out of bounds trying
        // to get existing attributes at index 0, which doesn't exist.
        return;
    }
    
    [string setAttributes:self.baseAttributes range:NSMakeRange(0, string.length)];
    
    ZSWTaggedStringAttribute *unknownTagWrapper = self._private_unknownTagWrapper;
    
    for (ZSWStringParserTag *tag in tags) {
        ZSWTaggedStringAttribute *tagValue = self._private_tagToAttributesMap[tag.tagName.lowercaseString];
        NSDictionary<NSAttributedStringKey, id> *attributes = nil;
        
        if (tagValue) {
            attributes = [tagValue attributesForTag:tag forString:string];
        } else if (unknownTagWrapper) {
            attributes = [unknownTagWrapper attributesForTag:tag forString:string];
        }
        
        if (attributes) {
            [string addAttributes:attributes range:tag.tagRange];
        }
    }
}

@end
