//
//  DataDetectorsObjectiveCViewController.m
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2019 Zachary West. All rights reserved.
//

#import "DataDetectorsObjectiveCViewController.h"

@import Masonry;
@import ZSWTappableLabel;
@import SafariServices;

static NSString *const TextCheckingResultAttributeName = @"TextCheckingResultAttributeName";

@interface DataDetectorsObjectiveCViewController () <ZSWTappableLabelTapDelegate>
@property (nonatomic) ZSWTappableLabel *label;
@end

@implementation DataDetectorsObjectiveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.label = ^{
        ZSWTappableLabel *label = [[ZSWTappableLabel alloc] init];
        label.tapDelegate = self;
        label.adjustsFontForContentSizeCategory = YES;
        return label;
    }();
    
    NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllSystemTypes error:NULL];
    NSString *string = @"did you check google.com or call 415-555-5555? how about friday at 5pm?";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
    }];

    [dataDetector enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[ZSWTappableLabelTappableRegionAttributeName] = @YES;
        attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = [UIColor lightGrayColor];
        attributes[ZSWTappableLabelHighlightedForegroundAttributeName] = [UIColor whiteColor];
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
        attributes[TextCheckingResultAttributeName] = result;
        [attributedString addAttributes:attributes range:result.range];
    }];
    self.label.attributedText = attributedString;
    
    [self.view addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - ZSWTappableLabelTapDelegate

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel tappedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSURL *URL;
    
    NSTextCheckingResult *result = attributes[TextCheckingResultAttributeName];
    if ([result isKindOfClass:[NSTextCheckingResult class]]) {
        switch (result.resultType) {
            case NSTextCheckingTypeAddress:
                NSLog(@"Address components: %@", result.addressComponents);
                break;
                
            case NSTextCheckingTypePhoneNumber: {
                NSURLComponents *components = [[NSURLComponents alloc] init];
                components.scheme = @"tel";
                components.host = result.phoneNumber;
                URL = components.URL;
                break;
            }
                
            case NSTextCheckingTypeDate:
                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
                URL = result.URL;
                break;
                
            default:
                break;
        }
    }
    
    if ([URL isKindOfClass:[NSURL class]]) {
        if ([SFSafariViewController class] != nil && [@[ @"http", @"https"] containsObject:URL.scheme.lowercaseString]) {
            [self showViewController:[[SFSafariViewController alloc] initWithURL:URL] sender:self];
        } else {
            [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
        }
    }
}

@end
