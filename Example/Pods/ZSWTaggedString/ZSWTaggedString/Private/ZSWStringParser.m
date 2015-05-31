//
//  ZSWStringParser.m
//  Pods
//
//  Created by Zachary West on 2015-02-21.
//
//

#import "ZSWStringParser.h"
#import "ZSWStringParser.h"
#import "ZSWStringParserTag.h"
#import "ZSWTaggedStringOptions.h"

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
                   returnClass:(Class)returnClass {
    if (!taggedString.underlyingString) {
        if (options.returnEmptyStringForNil) {
            return [[returnClass alloc] init];
        } else {
            return nil;
        }
    }
    
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
            // We found a tag start, but it's one that's been escaped. Skip it.
            [pendingString deleteCharactersInRange:NSMakeRange(pendingString.length - 1, 1)];
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
            [NSException raise:NSInvalidArgumentException
                        format:@"String had ending tag %@ when we expected ending tag %@ or new tag",
                                    tag.tagName, lastTag.tagName];
        } else {
            [tagStack addObject:tag];
        }
    }
    
    if (tagStack.count) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Reached end of string with %@ tags remaining (%@)",
                                @(tagStack.count), [[tagStack valueForKey:@"tagName"] componentsJoinedByString:@", "]];
    }
    
    if ([returnClass isEqual:[NSAttributedString class]]) {
        [options updateAttributedString:pendingString updatedWithTags:finishedTags];
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
