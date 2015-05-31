//
//  ZSWTaggedString.m
//  Pods
//
//  Created by Zachary West on 2015-02-21.
//
//

#import "ZSWTaggedString.h"
#import "ZSWStringParser.h"
#import "ZSWTaggedStringOptions.h"

@implementation ZSWTaggedString

+ (ZSWTaggedString *)stringWithString:(NSString *)string {
    return [[[self class] alloc] initWithString:string];
}

+ (ZSWTaggedString *)stringWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *combinedString = [[NSString alloc] initWithFormat:format
                                                      arguments:args];
    va_end(args);
    
    return [self stringWithString:combinedString];
}

- (void)commonInit {
    
}

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        [self commonInit];
        
        self.underlyingString = string;
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
        
        self.underlyingString = [decoder decodeObjectOfClass:[NSString class]
                                                      forKey:ZSWSelector(underlyingString)];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.underlyingString forKey:ZSWSelector(underlyingString)];
}

- (id)copyWithZone:(NSZone *)zone {
    ZSWTaggedString *taggedString = [[ZSWTaggedString allocWithZone:zone] init];
    taggedString->_underlyingString = self->_underlyingString;
    return taggedString;
}

- (BOOL)isEqual:(ZSWTaggedString *)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (!self.underlyingString && !object.underlyingString) {
        return YES;
    } else {
        return [object.underlyingString isEqualToString:self.underlyingString];
    }
}

- (NSUInteger)hash {
    return self.underlyingString.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; underlying: \"%@\">",
            NSStringFromClass([self class]), self, self.underlyingString];
}

#pragma mark - Generation

- (NSString *)string {
    return [self stringWithOptions:[ZSWTaggedStringOptions defaultOptionsNoCopy]];
}

- (NSString *)stringWithOptions:(ZSWTaggedStringOptions *)options {
    NSParameterAssert(options != nil);
    
    return [ZSWStringParser stringWithTaggedString:self
                                           options:options
                                       returnClass:[NSString class]];
}

- (NSAttributedString *)attributedString {
    return [self attributedStringWithOptions:[ZSWTaggedStringOptions defaultOptionsNoCopy]];
}

- (NSAttributedString *)attributedStringWithOptions:(ZSWTaggedStringOptions *)options {
    NSParameterAssert(options != nil);
    
    return [ZSWStringParser stringWithTaggedString:self
                                           options:options
                                       returnClass:[NSAttributedString class]];
}

@end
