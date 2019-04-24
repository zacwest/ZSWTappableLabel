//
//  InterfaceBuilderObjectiveCViewController.m
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2019 Zachary West. All rights reserved.
//

#import "InterfaceBuilderObjectiveCViewController.h"

@import ZSWTappableLabel;
@import SafariServices;

@interface InterfaceBuilderObjectiveCViewController ()
@property (weak, nonatomic) IBOutlet ZSWTappableLabel *label;

@end

@implementation InterfaceBuilderObjectiveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString *attributedText = [self.label.attributedText mutableCopy];
    NSRange range = [attributedText.string rangeOfString:@"label"];
    if (range.location != NSNotFound) {
        [attributedText addAttributes:@{
            ZSWTappableLabelTappableRegionAttributeName: @YES,
            NSLinkAttributeName: [NSURL URLWithString:@"https://gotofail.com"],
            ZSWTappableLabelHighlightedBackgroundAttributeName: [UIColor lightGrayColor]
        } range:range];
        self.label.attributedText = attributedText;
    }
}


#pragma mark - ZSWTappableLabelTapDelegate

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel tappedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSURL *URL = attributes[NSLinkAttributeName];
    if ([URL isKindOfClass:[NSURL class]]) {
        [self showViewController:[[SFSafariViewController alloc] initWithURL:URL] sender:self];
    }
}

@end
