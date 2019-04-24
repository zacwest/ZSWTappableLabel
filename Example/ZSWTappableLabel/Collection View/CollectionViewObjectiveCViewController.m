//
//  CollectionViewObjectiveCViewController.m
//  ZSWTappableLabel_Example
//
//  Created by Zac West on 4/21/19.
//  Copyright © 2019 Zachary West. All rights reserved.
//

#import "CollectionViewObjectiveCViewController.h"

@import Masonry;
@import ZSWTappableLabel;
@import SafariServices;

@interface CollectionViewObjectiveCCell : UICollectionViewCell
@property (nonatomic) ZSWTappableLabel *label;
@end

@implementation CollectionViewObjectiveCCell
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.label = [[ZSWTappableLabel alloc] init];
        self.label.adjustsFontForContentSizeCategory = YES;
        [self.contentView addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        // Mostly to demonstrate that you can tap without selecting, make it ugly and red when selected.
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = UIColor.redColor;
    }
    return self;
}
@end

@interface CollectionViewObjectiveCViewController () <UICollectionViewDelegateFlowLayout, ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate>

@end

@implementation CollectionViewObjectiveCViewController

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = UIColor.whiteColor;
    self.collectionView.allowsSelection = YES;
    [self.collectionView registerClass:[CollectionViewObjectiveCCell class]
            forCellWithReuseIdentifier:@"Cell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Not bothering to size these cells in this example
    return CGSizeMake(100, 60);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewObjectiveCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.label.longPressDelegate = self;
    cell.label.tapDelegate = self;
    
    cell.label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Hello %ld", (long)indexPath.item] attributes:@{
        NSLinkAttributeName: [NSURL URLWithString:[NSString stringWithFormat:@"https://google.com/search?q=index+%ld", (long)indexPath.item]],
        ZSWTappableLabelTappableRegionAttributeName: @YES,
        ZSWTappableLabelHighlightedBackgroundAttributeName: [UIColor lightGrayColor],
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCallout],
    }];
    
    return cell;
}

#pragma mark - ZSWTappableLabelTapDelegate

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel tappedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
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

@end
