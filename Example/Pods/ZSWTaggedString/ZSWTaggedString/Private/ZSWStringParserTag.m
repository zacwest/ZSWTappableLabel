//
//  ZSWStringParserTag.m
//  Pods
//
//  Created by Zachary West on 2015-02-21.
//
//

#import <ZSWTaggedString/ZSWStringParserTag.h>

@interface ZSWStringParserTag()
@property (nonatomic, readwrite) NSString *tagName;
@property (nonatomic, readwrite) NSUInteger location;
@property (nonatomic) NSUInteger endLocation;

@property (nonatomic) NSDictionary *tagAttributes;

#ifdef DEBUG
@property (nonatomic) NSString *rawAttributes;
#endif
@end

@implementation ZSWStringParserTag

- (instancetype)initWithTagName:(NSString *)tagName
                  startLocation:(NSUInteger)location {
    self = [super init];
    if (self) {
        self.tagName = tagName;
        self.location = location;
        self.tagAttributes = @{};
    }
    return self;
}

- (NSString *)description {
#ifdef DEBUG
    return [NSString stringWithFormat:@"<%@: %p; tag: %@, isEndingTag: %@, rawAttributes: %@, parsedAttributes: %@>",
            NSStringFromClass([self class]), self, self.tagName, self.isEndingTag ? @"YES" : @"NO", self.rawAttributes, self.tagAttributes];
#else
    return [NSString stringWithFormat:@"<%@: %p; tag: %@, isEndingTag: %@, parsedAttributes: %@>",
            NSStringFromClass([self class]), self, self.tagName, self.isEndingTag ? @"YES" : @"NO", self.tagAttributes];
#endif
}

- (BOOL)isEndingTag {
    return [self.tagName hasPrefix:@"/"];
}

- (BOOL)isEndedByTag:(ZSWStringParserTag *)tag {
    if (!tag.isEndingTag) {
        return NO;
    }
    
    if (![[tag.tagName.lowercaseString substringFromIndex:1] isEqualToString:self.tagName.lowercaseString]) {
        return NO;
    }
    
    return YES;
}

- (void)updateWithTag:(ZSWStringParserTag *)tag {
    NSAssert([self isEndedByTag:tag], @"Didn't check before updating tag");
    self.endLocation = tag.location;
}

- (NSRange)tagRange {
    if (self.endLocation < self.location) {
        return NSMakeRange(self.location, 0);
    } else {
        return NSMakeRange(self.location, self.endLocation - self.location);
    }
}

- (void)addRawTagAttributes:(NSString *)rawTagAttributes {
    NSScanner *scanner = [NSScanner scannerWithString:rawTagAttributes];
    scanner.charactersToBeSkipped = nil;
    
    NSMutableDictionary *tagAttributes = [NSMutableDictionary dictionary];
    
    NSCharacterSet *nameBreakSet = [NSCharacterSet characterSetWithCharactersInString:@" ="];
    NSCharacterSet *quoteCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\"" @"'"];
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
    
    while (!scanner.isAtEnd) {
        // eat any whitespace at the start
        [scanner scanCharactersFromSet:whitespaceSet intoString:NULL];
        
        if (scanner.isAtEnd) {
            // e.g., a tag like <dog ></dog> might produce just a space attribute
            break;
        }
        
        // Scan up to '=' or ' '
        NSString *attributeName;
        [scanner scanUpToCharactersFromSet:nameBreakSet intoString:&attributeName];
        
        NSString *breakString;
        [scanner scanCharactersFromSet:nameBreakSet intoString:&breakString];
        
        if (scanner.isAtEnd || [breakString rangeOfString:@"="].location == NSNotFound) {
            // No equal was found, so give some generic value.
            tagAttributes[attributeName] = [NSNull null];
        } else {
            // We had an equal! Yay! We can use the value.
            NSString *quote;
            BOOL ateQuote = [scanner scanCharactersFromSet:quoteCharacterSet intoString:&quote];
            
            NSString *attributeValue;
            if (ateQuote) {
                // For empty values (e.g. ''), we need to see if we scanned more than one quote.
                NSInteger count = 0;
                for (NSUInteger idx = 0; idx < quote.length; idx++) {
                    count += [quoteCharacterSet characterIsMember:[quote characterAtIndex:idx]];
                }
                
                if (count > 1) {
                    attributeValue = @"";
                } else {
                    [scanner scanUpToCharactersFromSet:quoteCharacterSet intoString:&attributeValue];
                    [scanner scanCharactersFromSet:quoteCharacterSet intoString:NULL];
                }
            } else {
                [scanner scanUpToCharactersFromSet:whitespaceSet intoString:&attributeValue];
                [scanner scanCharactersFromSet:whitespaceSet intoString:NULL];
            }
            
            tagAttributes[attributeName] = attributeValue ?: [NSNull null];
        }
    }
    
    if (tagAttributes.count) {
        NSMutableDictionary *updatedAttributes = [NSMutableDictionary dictionaryWithDictionary:self.tagAttributes];
        [updatedAttributes addEntriesFromDictionary:tagAttributes];
        self.tagAttributes = [updatedAttributes copy];
    }
    
#ifdef DEBUG
    if (rawTagAttributes.length) {
        NSMutableString *updatedRawAttributes = [NSMutableString stringWithString:self.rawAttributes ?: @""];
        [updatedRawAttributes appendString:rawTagAttributes];
        self.rawAttributes = updatedRawAttributes;
    }
#endif
}

@end
