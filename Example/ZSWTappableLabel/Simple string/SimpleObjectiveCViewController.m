//
//  SimpleObjectiveCViewController.m
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2019 Zachary West. All rights reserved.
//

#import "SimpleObjectiveCViewController.h"

@import Masonry;
@import ZSWTappableLabel;
@import SafariServices;

static NSString *const URLAttributeName = @"URL";

@interface SimpleObjectiveCViewController () <ZSWTappableLabelTapDelegate>
@property (nonatomic) ZSWTappableLabel *label;
@end

@implementation SimpleObjectiveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.label = ^{
        ZSWTappableLabel *label = [[ZSWTappableLabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontForContentSizeCategory = YES;
        label.tapDelegate = self;
        return label;
    }();
    
    NSString *string = NSLocalizedString(@"Privacy Policy", nil);
    NSDictionary *attributes = @{
        ZSWTappableLabelTappableRegionAttributeName: @YES,
        ZSWTappableLabelHighlightedBackgroundAttributeName: [UIColor lightGrayColor],
        ZSWTappableLabelHighlightedForegroundAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
        NSForegroundColorAttributeName: [UIColor blueColor],
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
        URLAttributeName: [NSURL URLWithString:@"http://imgur.com/gallery/VgXCk"],
    };
    
    self.label.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    [self.view addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - ZSWTappableLabelTapDelegate

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel tappedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey ,id> *)attributes {
    NSURL *URL = attributes[URLAttributeName];
    if ([URL isKindOfClass:[NSURL class]]) {
        [self showViewController:[[SFSafariViewController alloc] initWithURL:URL] sender:self];
    }
}

@end
