//
//  ZSWStringParser.m
//  Pods
//
//  Created by Zachary West on 2015-02-21.
//
//

#import <ZSWTaggedString/ZSWStringParser.h>
#import <ZSWTaggedString/ZSWStringParser.h>
#import <ZSWTaggedString/ZSWStringParserTag.h>
#import <ZSWTaggedString/ZSWTaggedStringOptions.h>
#import <ZSWTaggedString/ZSWTaggedString_Private.h>

static NSString *const kTagStart = @"<";
static NSString *const kTagEnd = @">";
static const unichar kTagIgnore = '\01';
static NSString *const kIgnoredTagStart = @"\01<";

@implementation ZSWStringParser

extern NSString *ZSWEscapedStringForString(NSString *unescapedString) {
    return [unescapedString stringByReplacingOccurrencesOfString:kTagStart
                                                      withString:kIgnoredTagStart];
}

+ (void)appendString:(NSString *)string intoAttributedString:(NSMutableAttributedString *)attributedString {
    if (!string.length) {
        return;
    }
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
}

+ (id)stringWithTaggedString:(ZSWTaggedString *)taggedString
                     options:(ZSWTaggedStringOptions *)options
                 returnClass:(Class)returnClass
                       error:(NSError **)error {
    BOOL parseTagAttributes = [returnClass isEqual:[NSAttributedString class]];
    
    NSScanner *scanner = [NSScanner scannerWithString:taggedString.underlyingString];
    scanner.charactersToBeSkipped = nil;
    
    NSMutableAttributedString *pendingString = [[NSMutableAttributedString alloc] init];
    NSMutableArray *tagStack = [NSMutableArray array];
    NSMutableArray *finishedTags = [NSMutableArray array];
    
    NSCharacterSet *tagStartCharacterSet = [NSCharacterSet characterSetWithCharactersInString:kTagStart];
    NSCharacterSet *tagEndCharacterSet = [NSCharacterSet characterSetWithCharactersInString:kTagEnd];
    
    while (!scanner.isAtEnd) {
        NSString *scratchString;
        [scanner scanUpToCharactersFromSet:tagStartCharacterSet intoString:&scratchString];
        [self appendString:scratchString intoAttributedString:pendingString];
        
        if (scanner.isAtEnd) {
            // No tag were found; we're done.
            break;
        }
        
        // Eat the < nom nom nom
        [scanner scanCharactersFromSet:tagStartCharacterSet intoString:NULL];
        
        if ([scratchString characterAtIndex:(scratchString.length - 1)] == kTagIgnore) {
            // We found a tag start, but it's one that's been escaped. Skip it, and append the start tag we just gobbled up.
            [pendingString deleteCharactersInRange:NSMakeRange(pendingString.length - 1, 1)];
            [self appendString:kTagStart intoAttributedString:pendingString];
            continue;
        }
        
        scratchString = nil;
        [scanner scanUpToCharactersFromSet:tagEndCharacterSet intoString:&scratchString];
        if (scanner.isAtEnd) {
            [self appendString:scratchString intoAttributedString:pendingString];
            break;
        }
        
        // Eat the > nom nom nom
        [scanner scanCharactersFromSet:tagEndCharacterSet intoString:NULL];
        
        NSScanner *tagScanner = [NSScanner scannerWithString:scratchString];
        NSString *tagName;
        BOOL scannedSpace = [tagScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&tagName];
        
        ZSWStringParserTag *tag = [[ZSWStringParserTag alloc] initWithTagName:tagName startLocation:pendingString.length];
        
        if (scannedSpace && parseTagAttributes) {
            [tagScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
            [tag addRawTagAttributes:[tagScanner.string substringFromIndex:tagScanner.scanLocation]];
        }
        
        ZSWStringParserTag *lastTag = tagStack.lastObject;
        if ([lastTag isEndedByTag:tag]) {
            [lastTag updateWithTag:tag];
            [tagStack removeLastObject];
            
            // We want to apply the attributes from the outer-most tags first, so put them at the start.
            [finishedTags insertObject:lastTag atIndex:0];
        } else if (tag.isEndingTag) {
            if (error) {
                *error = [NSError errorWithDomain:ZSWTaggedStringErrorDomain
                                            code:ZSWTaggedStringErrorCodeInvalidTags
                                        userInfo:@{ @"developerError": [NSString stringWithFormat:@"String had ending tag %@ when we expected ending tag %@ or new tag", tag.tagName, lastTag.tagName] }];
            }
            
            return nil;
        } else {
            [tagStack addObject:tag];
        }
    }
    
    if (tagStack.count) {
        if (error) {
            *error = [NSError errorWithDomain:ZSWTaggedStringErrorDomain
                                         code:ZSWTaggedStringErrorCodeInvalidTags
                                     userInfo:@{ @"developerError": [NSString stringWithFormat:@"Reached end of string with %@ tags remaining (%@)", @(tagStack.count), [[tagStack valueForKey:@"tagName"] componentsJoinedByString:@", "]] }];
        }
        
        return nil;
    }
    
    if ([returnClass isEqual:[NSAttributedString class]]) {
        [options _private_updateAttributedString:pendingString updatedWithTags:finishedTags];
        return [pendingString copy];
    } else if ([returnClass isEqual:[NSString class]]) {
        return [pendingString.string copy];
    } else {        
        [NSException raise:NSInternalInconsistencyException
                    format:@"Somehow asked for class type %@ for parsed string",
                                    NSStringFromClass(returnClass)];
        return nil;
    }
}

@end
