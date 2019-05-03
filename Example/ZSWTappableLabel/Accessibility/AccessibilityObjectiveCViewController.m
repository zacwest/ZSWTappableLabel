//
//  AccessibilityObjectiveCViewController.m
//  ZSWTappableLabel_Example
//
//  Created by Zac West on 4/21/19.
//  Copyright © 2019 Zachary West. All rights reserved.
//

#import "AccessibilityObjectiveCViewController.h"

@import Masonry;
@import ZSWTappableLabel;
@import SafariServices;

@interface ObjcViewLinkCustomAction : UIAccessibilityCustomAction
@property (nonatomic) NSRange range;
@property (nonatomic) NSDictionary<NSAttributedStringKey, id> *attributes;
@end

@implementation ObjcViewLinkCustomAction
@end

@interface AccessibilityObjectiveCViewController() <ZSWTappableLabelTapDelegate, ZSWTappableLabelAccessibilityDelegate>
@property (nonatomic) ZSWTappableLabel *label;
@end

@implementation AccessibilityObjectiveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.label = ^{
        ZSWTappableLabel *label = [[ZSWTappableLabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontForContentSizeCategory = YES;
        label.tapDelegate = self;
        label.accessibilityDelegate = self;
        return label;
    }();

    NSString *string = NSLocalizedString(@"Privacy Policy", nil);
    NSDictionary<NSAttributedStringKey, id> *attributes = @{
        ZSWTappableLabelTappableRegionAttributeName: @YES,
        ZSWTappableLabelHighlightedBackgroundAttributeName: [UIColor lightGrayColor],
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
        NSLinkAttributeName: [NSURL URLWithString:@"http://imgur.com/gallery/VgXCk"],
    };
    
    self.label.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    [self.view addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (BOOL)viewLink:(ObjcViewLinkCustomAction *)action {
    NSURL *URL = action.attributes[NSLinkAttributeName];

    __weak __typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:URL.absoluteString message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Open URL", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showViewController:[[SFSafariViewController alloc] initWithURL:URL] sender:weakSelf];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];

    return YES;
}

#pragma mark - ZSWTappableLabelTapDelegate

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel tappedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey ,id> *)attributes {
    NSURL *URL = attributes[NSLinkAttributeName];
    if ([URL isKindOfClass:[NSURL class]]) {
        [self showViewController:[[SFSafariViewController alloc] initWithURL:URL] sender:self];
    }
}

#pragma mark - ZSWTappableLabelAccessibilityDelegate

- (NSArray<UIAccessibilityCustomAction *> *)tappableLabel:(ZSWTappableLabel *)tappableLabel accessibilityCustomActionsForCharacterRange:(NSRange)characterRange withAttributesAtStart:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    ObjcViewLinkCustomAction *customAction = [[ObjcViewLinkCustomAction alloc] initWithName:NSLocalizedString(@"View Link Address", nil) target:self selector:@selector(viewLink:)];
    customAction.range = characterRange;
    customAction.attributes = attributes;
    return @[ customAction ];
}

- (nullable NSString *)tappableLabel:(nonnull ZSWTappableLabel *)tappableLabel accessibilityLabelForCharacterRange:(NSRange)characterRange withAttributesAtStart:(nonnull NSDictionary<NSAttributedStringKey,id> *)attributes {
    // The Swift example overrides, the Objective-C example does not.
    return nil;
}

@end
