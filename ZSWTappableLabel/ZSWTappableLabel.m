//
//  ZSWTappableLabel.m
//  ZSWTappableLabel
//
//  Created by Zachary West on 3/23/15.
//  Copyright (c) 2015 Zachary West. All rights reserved.
//
//  MIT License
//  https://github.com/zacwest/ZSWTappableLabel
//

#import "ZSWTappableLabel.h"

NSString *const ZSWTappableLabelHighlightedBackgroundAttributeName = @"ZSWTappableLabelHighlightedBackgroundAttributeName";
NSString *const ZSWTappableLabelTappableRegionAttributeName = @"ZSWTappableLabelTappableRegionAttributeName";
NSString *const ZSWTappableLabelHighlightedForegroundAttributeName = @"ZSWTappableLabelHighlightedForegroundAttributeName";

@interface ZSWTappableLabel() <UIGestureRecognizerDelegate>
@property (nonatomic) NSArray *accessibleElements;
@property (nonatomic) CGRect lastAccessibleElementsFrame;

@property (nonatomic) NSAttributedString *unmodifiedAttributedText;

@property (nonatomic) NSTextStorage *gestureTextStorage;
@property (nonatomic) CGPoint gesturePointOffset;

@property (nonatomic) UILongPressGestureRecognizer *longPressGR;
@property (nonatomic) UITapGestureRecognizer *tapGR;
@end

@implementation ZSWTappableLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self tappableLabelCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tappableLabelCommonInit];
    }
    return self;
}

- (void)tappableLabelCommonInit {
    self.userInteractionEnabled = YES;
    
    self.numberOfLines = 0;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    self.longPressGR.delegate = self;
    self.longPressGR.minimumPressDuration = 0.15; // trying to match timing of UICollectionView's highlight LPGR
    [self addGestureRecognizer:self.longPressGR];
    
    self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.tapGR.delegate = self;
    [self addGestureRecognizer:self.tapGR];
}

- (void)createTextStorage {
    if (self.gestureTextStorage) {
        return;
    }
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.unmodifiedAttributedText];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

    textContainer.lineBreakMode = self.lineBreakMode;
    textContainer.maximumNumberOfLines = self.numberOfLines;
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    
    [textStorage addLayoutManager:layoutManager];

    self.gestureTextStorage = textStorage;
    
    // UITextView vertically centers if it doesn't fill the whole bounds, so compensate for that.
    CGRect usedRect = [layoutManager usedRectForTextContainer:textContainer];
    self.gesturePointOffset = CGPointMake(0, (CGRectGetHeight(self.bounds) - CGRectGetHeight(usedRect))/2.0);
}

- (void)destroyTextStorageIfNeeded {
    BOOL (^isEnded)(UIGestureRecognizer *) = ^(UIGestureRecognizer *gestureRecognizer) {
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged:
            case UIGestureRecognizerStatePossible:
                return NO;
                
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateFailed:
                return YES;
        }
        
        return YES;
    };
    
    if (isEnded(self.tapGR) && isEnded(self.longPressGR)) {
        self.gestureTextStorage = nil;
    }
}

- (void)performWithLayoutManager:(void(^)(NSUInteger (^characterIndexAtPoint)(CGPoint point),
                                          CGRect (^screenFrameForCharacterRange)(NSRange characterRange)))layoutManagerBlock
      ignoringGestureRecognizers:(BOOL)ignoreGestureRecognizers {
    [self createTextStorage];
    
    NSTextStorage *textStorage = self.gestureTextStorage;
    NSLayoutManager *layoutManager = textStorage.layoutManagers.lastObject;
    NSTextContainer *textContainer = layoutManager.textContainers.lastObject;
    CGPoint pointOffset = self.gesturePointOffset;
    
    NSUInteger (^characterIndexAtPoint)(CGPoint) = ^NSUInteger(CGPoint point) {
        point.x -= pointOffset.x;
        point.y -= pointOffset.y;
        
        CGFloat fractionOfDistanceBetween;
        NSUInteger characterIdx = [layoutManager characterIndexForPoint:point
                                                        inTextContainer:textContainer
                               fractionOfDistanceBetweenInsertionPoints:&fractionOfDistanceBetween];
        
        characterIdx = MIN(textStorage.length - 1, characterIdx + fractionOfDistanceBetween);

        NSRange glyphRange = [layoutManager glyphRangeForCharacterRange:NSMakeRange(characterIdx, 1) actualCharacterRange:NULL];
        CGRect glyphRect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
        
        // plus some padding to make it easier in some cases
        glyphRect = CGRectInset(glyphRect, -10, -10);

        if (!CGRectContainsPoint(glyphRect, point)) {
            characterIdx = NSNotFound;
        }
        
        return characterIdx;
    };
    
    CGRect (^sreenFrameForCharacterRange)(NSRange) = ^(NSRange characterRange) {
        NSRange glyphRange = [layoutManager glyphRangeForCharacterRange:characterRange actualCharacterRange:NULL];
        CGRect viewFrame = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
        viewFrame.origin.x += pointOffset.x;
        viewFrame.origin.y += pointOffset.y;
        return UIAccessibilityConvertFrameToScreenCoordinates(viewFrame, self);
    };
    
    layoutManagerBlock(characterIndexAtPoint, sreenFrameForCharacterRange);
    
    if (ignoreGestureRecognizers) {
        self.gestureTextStorage = nil;
    } else {
        [self destroyTextStorageIfNeeded];
    }
}

#pragma mark - Overloading

- (void)setText:(NSString *)text {
    if (text) {
        [self setAttributedText:[[NSAttributedString alloc] initWithString:text attributes:nil]];
    } else {
        [self setAttributedText:nil];
    }
}

- (NSString *)text {
    return self.unmodifiedAttributedText.string;
}

- (void)setUnmodifiedAttributedText:(NSAttributedString *)unmodifiedAttributedText {
    _unmodifiedAttributedText = unmodifiedAttributedText;
    _accessibleElements = nil;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    
    __block BOOL containsTappableRegion = NO;
    [attributedText enumerateAttribute:ZSWTappableLabelTappableRegionAttributeName
                               inRange:NSMakeRange(0, attributedText.length)
                               options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                            usingBlock:^(id value, NSRange range, BOOL *stop) {
                                if ([value boolValue]) {
                                    *stop = YES;
                                    containsTappableRegion = YES;
                                }
                            }];
    
    if (containsTappableRegion) {
        self.tapGR.enabled = YES;
        self.longPressGR.enabled = YES;
        
        // If the user doesn't specify a font, UILabel is going to render with the current
        // one it wants, so we need to fill in the blanks
        NSMutableAttributedString *mutableText = [attributedText mutableCopy];
        UIFont *font = [super font];
        
        [attributedText enumerateAttribute:NSFontAttributeName
                                   inRange:NSMakeRange(0, attributedText.length)
                                   options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                usingBlock:^(id value, NSRange range, BOOL *stop) {
                                    if (!value) {
                                        [mutableText addAttribute:NSFontAttributeName
                                                            value:font
                                                            range:range];
                                    }
                                }];
        
        attributedText = mutableText;
    } else {
        self.tapGR.enabled = NO;
        self.longPressGR.enabled = NO;
    }
    
    self.unmodifiedAttributedText = attributedText;
}

- (NSAttributedString *)attributedText {
    return self.unmodifiedAttributedText;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    __block BOOL shouldReceive = NO;

    if ([self.tapDelegate respondsToSelector:@selector(tappableLabelShouldPassThroughUnhighlightedTouches:)])
    {
        shouldReceive = ![self.tapDelegate tappableLabelShouldPassThroughUnhighlightedTouches:self];
    }
    else
    {
        [self performWithLayoutManager:^(NSUInteger (^characterIndexAtPoint)(CGPoint point),
                                         CGRect (^screenFrameForCharacterRange)(NSRange characterRange)) {
            NSUInteger characterIdx = characterIndexAtPoint([touch locationInView:self]);

            if (characterIdx != NSNotFound) {
                NSNumber *attribute = [self.unmodifiedAttributedText attribute:ZSWTappableLabelTappableRegionAttributeName
                                                                       atIndex:characterIdx
                                                                effectiveRange:NULL];
                shouldReceive = [attribute boolValue];
            } else {
                shouldReceive = NO;
            }
        } ignoringGestureRecognizers:YES];
    }

    return shouldReceive;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer == self.tapGR || otherGestureRecognizer == self.longPressGR) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Gestures

- (void)applyHighlightAtIndex:(NSUInteger)characterIndex {
    if (characterIndex == NSNotFound) {
        [self removeHighlight];
        return;
    }
    
    NSMutableAttributedString *attributedString = [self.unmodifiedAttributedText mutableCopy];
    
    NSRange highlightEffectiveRange = NSMakeRange(0, 0), foregroundEffectiveRange = NSMakeRange(0, 0);
    UIColor *highlightColor = [attributedString attribute:ZSWTappableLabelHighlightedBackgroundAttributeName
                                                  atIndex:characterIndex
                                    longestEffectiveRange:&highlightEffectiveRange
                                                  inRange:NSMakeRange(0, attributedString.length)];
    
    UIColor *foregroundColor = [attributedString attribute:ZSWTappableLabelHighlightedForegroundAttributeName
                                                   atIndex:characterIndex
                                            longestEffectiveRange:&foregroundEffectiveRange
                                                   inRange:NSMakeRange(0, attributedString.length)];
    
    if (highlightColor || foregroundColor) {
        if (highlightColor) {
            [attributedString addAttribute:NSBackgroundColorAttributeName
                                     value:highlightColor
                                     range:highlightEffectiveRange];
        }
        
        if (foregroundColor) {
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:foregroundColor
                                     range:foregroundEffectiveRange];
        }
        
        [super setAttributedText:attributedString];
    } else {
        [self removeHighlight];
    }
}

- (void)removeHighlight {
    [super setAttributedText:self.unmodifiedAttributedText];
}

- (void)notifyForCharacterIndex:(NSUInteger)characterIndex {
    if (characterIndex == NSNotFound) {
        return;
    }
    
    NSDictionary *attributes = [self.unmodifiedAttributedText attributesAtIndex:characterIndex effectiveRange:NULL];
    
#if DEBUG
    NSLog(@"Tapped at index %@ with attributes %@", @(characterIndex), attributes);
#endif
    
    [self.tapDelegate tappableLabel:self
                      tappedAtIndex:characterIndex
                     withAttributes:attributes];
}

- (void)tap:(UITapGestureRecognizer *)tapGR {
    [self performWithLayoutManager:^(NSUInteger (^characterIndexAtPoint)(CGPoint point),
                                     CGRect (^screenFrameForCharacterRange)(NSRange characterRange)) {
        NSUInteger characterIndex = characterIndexAtPoint([tapGR locationInView:self]);
        
        if (characterIndex == NSNotFound) {
            return;
        }
        
        [self applyHighlightAtIndex:characterIndex];
        [self notifyForCharacterIndex:characterIndex];
        [self removeHighlight];
    } ignoringGestureRecognizers:NO];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGR {
    [self performWithLayoutManager:^(NSUInteger (^characterIndexAtPoint)(CGPoint point),
                                     CGRect (^screenFrameForCharacterRange)(NSRange characterRange)) {
        switch (longPressGR.state) {
            case UIGestureRecognizerStatePossible:
                // noop
                break;
                
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged: {
                if (CGRectContainsPoint(self.bounds, [longPressGR locationInView:self])) {
                    NSUInteger characterIndex = characterIndexAtPoint([longPressGR locationInView:self]);
                    [self applyHighlightAtIndex:characterIndex];
                } else {
                    [self removeHighlight];
                }
                break;
            }
                
            case UIGestureRecognizerStateEnded: {
                NSUInteger characterIndex = characterIndexAtPoint([longPressGR locationInView:self]);
                [self notifyForCharacterIndex:characterIndex];
                [self removeHighlight];
                break;
            }
                
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
                // don't do anything; just remove highlight
                [self removeHighlight];
                break;
        }
    } ignoringGestureRecognizers:NO];
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return NO; // because we're a container
}

- (NSArray *)accessibleElements {
    if (_accessibleElements && CGRectEqualToRect(self.lastAccessibleElementsFrame, self.frame)) {
        return _accessibleElements;
    }
    
    NSMutableArray *accessibleElements = [NSMutableArray array];
    NSAttributedString *unmodifiedAttributedString = self.unmodifiedAttributedText;
    
    [self performWithLayoutManager:^(NSUInteger (^characterIndexAtPoint)(CGPoint point),
                                     CGRect (^screenFrameForCharacterRange)(NSRange characterRange)) {
        if (!unmodifiedAttributedString.length) {
            return;
        }
        
        void (^enumerationBlock)(id, NSRange, BOOL *) = ^(id value, NSRange range, BOOL *stop) {
            UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
            element.accessibilityLabel = [unmodifiedAttributedString.string substringWithRange:range];
            element.accessibilityFrame = screenFrameForCharacterRange(range);
            
            if ([value boolValue]) {
                element.accessibilityTraits = UIAccessibilityTraitLink | UIAccessibilityTraitStaticText;
            } else {
                element.accessibilityTraits = UIAccessibilityTraitStaticText;
            }
            
            [accessibleElements addObject:element];
        };
        
        [unmodifiedAttributedString enumerateAttribute:ZSWTappableLabelTappableRegionAttributeName
                                               inRange:NSMakeRange(0, unmodifiedAttributedString.length)
                                               options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                            usingBlock:enumerationBlock];
    } ignoringGestureRecognizers:YES];

    _accessibleElements = [accessibleElements copy];
    _lastAccessibleElementsFrame = self.frame;

    return _accessibleElements;
}

- (NSInteger)accessibilityElementCount {
    return [self accessibleElements].count;
}

- (id)accessibilityElementAtIndex:(NSInteger)idx {
    return [self accessibleElements][idx];
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return [[self accessibleElements] indexOfObject:element];
}

@end
