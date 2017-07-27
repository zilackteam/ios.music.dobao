//
//  PlaylistCollectionViewController.m
//  music.application
//
//  Created by thanhvu on 3/23/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "PlaylistCollectionViewController.h"

@interface PlaylistCollectionViewController()<AppPlaylistCollectionDataSource>
@end

@implementation PlaylistCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.alpha = 0;
    self.view.backgroundColor = RGBA(1, 1, 1, 0.85);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - AppPlaylistCollectionDataSource
- (void)playlistCollectionView:(UICollectionView *)collectionView contentView:(UIView *)contentView {
    collectionView.layer.cornerRadius = 5.0f;
    collectionView.layer.borderColor = RGBA(34, 34, 34, 1).CGColor;
    collectionView.layer.borderWidth = 1;
    collectionView.backgroundColor  = RGBA(1, 1, 1, 0.5);
    
    collectionView.backgroundColor  = RGBA(1, 1, 1, 0.5);
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 0;
    currentLayout.minimumInteritemSpacing = 0;
    
    float edge = 0.0f;
    collectionView.contentInset = UIEdgeInsetsMake(edge, edge, edge, edge);
    collectionView.allowsSelection = YES;
    [currentLayout invalidateLayout];
}

@end
