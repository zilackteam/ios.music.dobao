//
//  CardListCollectionViewController.m
//  music.application
//
//  Created by thanhvu on 4/26/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "CardListCollectionViewController.h"

@implementation CardlistCollectionOptionCell

@end


#define CARD_INFO_HEIGHT_OF_HEADER      50.0f
#define CARD_INFO_NUMBER_OF_ITEM        4
#define CARD_INFO_HEIGHT_OF_ITEM        80.0f
#define CARD_INFO_HEIGHT_OF_FOOTER      20.0f;

@interface CardListCollectionViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) NSMutableArray *items;

- (void)p_fetchData;
@end

@implementation CardListCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float edge = 10.0f;
    
    _titleLabel.text = LocalizedString(@"tlt_choise_card");
    
    self.view.alpha = 0;
    self.view.backgroundColor = RGBA(1, 1, 1, 0.85);
    self.contentView.layer.cornerRadius = 5.0f;
    self.contentView.layer.borderColor = RGBA(222, 186, 74, 1).CGColor;
    self.contentView.layer.borderWidth = 1;
    self.contentView.backgroundColor  = RGBA(1, 1, 1, 0.5);
    
    self.collectionView.backgroundColor  = RGBA(1, 1, 1, 0.5);
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 0;
    currentLayout.minimumInteritemSpacing = 0;
    
    self.collectionView.contentInset = UIEdgeInsetsMake(edge, edge, edge, edge);
    self.collectionView.allowsSelection = YES;
    [currentLayout invalidateLayout];
    
    _contentHeightConstraint.constant = CARD_INFO_HEIGHT_OF_HEADER + CARD_INFO_HEIGHT_OF_FOOTER;
    
    [self.view layoutIfNeeded];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self p_fetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dissmis:(void(^)(void))completion {
    _contentHeightConstraint.constant = CARD_INFO_HEIGHT_OF_HEADER + CARD_INFO_HEIGHT_OF_FOOTER;// 10 for extend
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)p_fetchData {
    NSString *name = ([AppSettings language] == LanguageEnglish)?@"en.lproj/card":@"vi.lproj/card";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    _items = [NSMutableArray arrayWithContentsOfFile:path];
    
    [_collectionView performBatchUpdates:^{
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
    }];
    
    int numberOfLines =  MIN((int)_items.count, CARD_INFO_NUMBER_OF_ITEM);
    
    _contentHeightConstraint.constant = numberOfLines  * CARD_INFO_HEIGHT_OF_ITEM + CARD_INFO_HEIGHT_OF_HEADER + CARD_INFO_HEIGHT_OF_FOOTER;
    
    [UIView animateWithDuration:0.5 delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.alpha = 1.0;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                     }];
    
}

#pragma mark - Touch
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dissmis:nil];
}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!_items) {
        return 0;
    }
    return [_items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CardlistCollectionOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    int row = (int)indexPath.item;
    NSDictionary *card = _items[row];
    
    NSString *name = card[@"name"];
    
    cell.titleLabel.text = name;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat contentSize = _collectionView.bounds.size.width;
    UIEdgeInsets insets = collectionView.contentInset;
    CGSize size = CGSizeMake(contentSize - insets.left - insets.right, CARD_INFO_HEIGHT_OF_ITEM);
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

@end
