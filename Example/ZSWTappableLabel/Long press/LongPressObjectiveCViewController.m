//
//  LongPressObjectiveCViewController.m
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/20/15.
//  Copyright © 2019 Zachary West. All rights reserved.
//

#import "LongPressObjectiveCViewController.h"

@import Masonry;
@import ZSWTappableLabel;
@import ZSWTaggedString;
@import SafariServices;

static NSString *const URLAttributeName = @"URL";

@interface LongPressObjectiveCViewController() <ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate>
@property (nonatomic) ZSWTappableLabel *label;
@end

@implementation LongPressObjectiveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.label = ^{
        ZSWTappableLabel *label = [[ZSWTappableLabel alloc] init];
        label.textAlignment = NSTextAlignmentJustified;
        label.adjustsFontForContentSizeCategory = YES;
        label.tapDelegate = self;
        label.longPressDelegate = self;
        label.longPressAccessibilityActionName = NSLocalizedString(@"Share", nil);
        return label;
    }();
    
    ZSWTaggedStringOptions *options = [ZSWTaggedStringOptions optionsWithBaseAttributes:@{
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
    }];
    [options setDynamicAttributes:^NSDictionary *(NSString *tagName,
                                                  NSDictionary *tagAttributes,
                                                  NSDictionary *existingStringAttributes) {
        NSURL *URL;
        if ([tagAttributes[@"type"] isEqualToString:@"privacy"]) {
            URL = [NSURL URLWithString:@"http://google.com/search?q=privacy"];
        } else if ([tagAttributes[@"type"] isEqualToString:@"tos"]) {
            URL = [NSURL URLWithString:@"http://google.com/search?q=tos"];
        }
        
        if (!URL) {
            return nil;
        }
        
        return @{
                 ZSWTappableLabelTappableRegionAttributeName: @YES,
                 ZSWTappableLabelHighlightedBackgroundAttributeName: [UIColor lightGrayColor],
                 ZSWTappableLabelHighlightedForegroundAttributeName: [UIColor whiteColor],
                 NSForegroundColorAttributeName: [UIColor blueColor],
                 NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                 @"URL": URL
                 };
    } forTagName:@"link"];
    
    NSString *string = NSLocalizedString(@"Please, feel free to peruse and enjoy our wonderful and alluring <link type='privacy'>Privacy Policy</link> or if you'd really like to understand what you're allowed or not allowed to do, reading our <link type='tos'>Terms of Service</link> is sure to be enlightening", nil);
    self.label.attributedText = [[ZSWTaggedString stringWithString:string] attributedStringWithOptions:options];
    
    [self.view addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - ZSWTappableLabelTapDelegate

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel tappedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSURL *URL = attributes[URLAttributeName];
    if ([URL isKindOfClass:[NSURL class]]) {
        [self showViewController:[[SFSafariViewController alloc] initWithURL:URL] sender:self];
    }
}

#pragma mark - ZSWTappableLabelLongPressDelegate

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel longPressedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSURL *URL = attributes[URLAttributeName];
    if ([URL isKindOfClass:[NSURL class]]) {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[ URL ] applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

@end
