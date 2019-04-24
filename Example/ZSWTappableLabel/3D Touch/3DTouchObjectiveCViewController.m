//
//  DDDTouchObjectiveCViewController.m
//  ZSWTappableLabel_Example
//
//  Created by Zac West on 4/21/19.
//  Copyright © 2019 Zachary West. All rights reserved.
//

#import "3DTouchObjectiveCViewController.h"

@import Masonry;
@import ZSWTappableLabel;
@import SafariServices;

@interface DDDTouchObjectiveCViewController() <ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate, UIViewControllerPreviewingDelegate>
@property (nonatomic) ZSWTappableLabel *label;
@end

@implementation DDDTouchObjectiveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.label = ^{
        ZSWTappableLabel *label = [[ZSWTappableLabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontForContentSizeCategory = YES;
        label.tapDelegate = self;
        label.longPressDelegate = self;
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
    
    [self registerForPreviewingWithDelegate:self sourceView:self.label];
}

#pragma mark - ZSWTappableLabelTapDelegate

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel tappedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey ,id> *)attributes {
    NSURL *URL = attributes[NSLinkAttributeName];
    if ([URL isKindOfClass:[NSURL class]]) {
        [self showViewController:[[SFSafariViewController alloc] initWithURL:URL] sender:self];
    }
}

#pragma mark - ZSWTappableLabelLongPressDelegate

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel longPressedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSURL *URL = attributes[NSLinkAttributeName];
    if ([URL isKindOfClass:[NSURL class]]) {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[ URL ] applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

#pragma mark - UIViewControllerPreviewingDelegate
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    id<ZSWTappableLabelTappableRegionInfo> regionInfo = [self.label tappableRegionInfoForPreviewingContext:previewingContext location:location];
    if (!regionInfo) {
        return nil;
    }
    NSURL *URL = regionInfo.attributes[NSLinkAttributeName];
    [regionInfo configurePreviewingContext:previewingContext];
    return [[SFSafariViewController alloc] initWithURL:URL];
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}

@end
