//
//  VideoCategoriesViewController.m
//  music.application
//
//  Created by thanhvu on 3/23/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "VideoCategoriesViewController.h"
#import "APIClient.h"
#import "CategoryList.h"

@interface VideoCategoriesViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) CategoryList *categoryList;
- (void)p_fetchData;

@end

@implementation VideoCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self useMainBackground];
    
    [self p_fetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)p_fetchData {
    [[APIClient shared] getCategories:CategoryTypeVideo completion:^(CategoryList *categories, BOOL success) {
        _categoryList = categories;
        [_collectionView reloadData];
    }];
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!_categoryList) {
        return 0;
    }
    return [_categoryList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeZero;
}


@end
