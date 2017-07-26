//
//  MediaActionViewController.m
//  music.application
//
//  Created by thanhvu on 3/22/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "MediaActionViewController.h"

@interface MediaActionViewController ()<AppMediaActionDataSource> {
}

@end

@implementation MediaActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AppMediaActionDataSource
- (void)mediaActionCollectionView:(UICollectionView *)collectionView {
    collectionView.layer.cornerRadius = 5.0f;
    collectionView.layer.borderColor = RGBA(0, 0, 0, 1).CGColor;
    collectionView.layer.borderWidth = 1;
    collectionView.backgroundColor  = RGBA(255, 255, 255, 0.9);
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 10;
    currentLayout.minimumInteritemSpacing = 10;
    
    collectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
    collectionView.allowsSelection = YES;
    [currentLayout invalidateLayout];
    
    [self.view layoutIfNeeded];
}
@end
