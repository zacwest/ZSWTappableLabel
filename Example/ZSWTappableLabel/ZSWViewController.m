//
//  ZSWViewController.m
//  ZSWTappableLabel
//
//  Created by Zachary West on 05/28/2015.
//  Copyright (c) 2014 Zachary West. All rights reserved.
//

#import "ZSWViewController.h"
#import <ZSWTappableLabel/ZSWTappableLabel.h>
#import <ZSWTaggedString/ZSWTaggedString.h>

@interface ZSWViewController () <ZSWTappableLabelTapDelegate>
@property (weak, nonatomic) IBOutlet ZSWTappableLabel *singleLabel;

@end

@implementation ZSWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    ZSWTappableLabel *label = self.singleLabel;
    
NSString *s = NSLocalizedString(@"Privacy Policy", nil);
NSDictionary *a = @{
  ZSWTappableLabelTappableRegionAttributeName: @YES,
  ZSWTappableLabelHighlightedBackgroundAttributeName: [UIColor lightGrayColor],
  ZSWTappableLabelHighlightedForegroundAttributeName: [UIColor whiteColor],
  NSForegroundColorAttributeName: [UIColor blueColor],
  NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
  @"URL": [NSURL URLWithString:@"http://imgur.com/gallery/VgXCk"],
};

label.attributedText = [[NSAttributedString alloc] initWithString:s attributes:a];

    
    label.tapDelegate = self;
    
ZSWTaggedStringOptions *options = [ZSWTaggedStringOptions options];
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

NSString *string = NSLocalizedString(@"View our <link type='privacy'>Privacy Policy</link> or <link type='tos'>Terms of Service</link>", nil);
label.attributedText = [[ZSWTaggedString stringWithString:string] attributedStringWithOptions:options];
    
    NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllSystemTypes error:NULL];
    string = @"did you check google.com or call 415-555-5555? how about friday at 5pm?";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:nil];
    // this throws an exception if string is nil - make sure you check
    [dataDetector enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[ZSWTappableLabelTappableRegionAttributeName] = @YES;
        attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = [UIColor lightGrayColor];
        attributes[ZSWTappableLabelHighlightedForegroundAttributeName] = [UIColor whiteColor];
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
        attributes[@"NSTextCheckingResult"] = result;
        [attributedString addAttributes:attributes range:result.range];
    }];
    label.attributedText = attributedString;
}

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary *)attributes {
  [[UIApplication sharedApplication] openURL:attributes[@"URL"]];
    
    if (attributes[@"NSTextCheckingResult"]) {
        NSTextCheckingResult *result = attributes[@"NSTextCheckingResult"];
        switch (result.resultType) {
            case NSTextCheckingTypeAddress:
                NSLog(@"Address components: %@", result.addressComponents);
                break;
                
            case NSTextCheckingTypePhoneNumber:
                NSLog(@"Phone number: %@", result.phoneNumber);
                break;
                
            case NSTextCheckingTypeDate:
                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
                NSLog(@"Link: %@", result.URL);
                break;
                
            default:
                break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
