//
//  PlaylistCollectionViewController.m
//  music.application
//
//  Created by thanhvu on 3/23/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "PlaylistCollectionViewController.h"

@implementation PlaylistCollectionOptionCell

@end

@interface PlaylistCollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) NSMutableArray *items;

- (void)p_fetchData;

@end

#define PLAYLIST_INFO_HEIGHT_OF_HEADER      60.0f
#define PLAYLIST_INFO_NUMBER_OF_ITEM        5
#define PLAYLIST_INFO_HEIGHT_OF_ITEM        70.0f
#define PLAYLIST_INFO_HEIGHT_OF_FOOTER      40.0f;


@interface PlaylistCollectionViewController()
@end

@implementation PlaylistCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float edge = 0.0f;
    
    _titleLabel.text = LocalizedString(@"tlt_playlist");
    self.view.alpha = 0;
    self.view.backgroundColor = RGBA(1, 1, 1, 0.85);
    self.contentView.layer.cornerRadius = 5.0f;
    self.contentView.layer.borderColor = RGBA(34, 34, 34, 1).CGColor;
    self.contentView.layer.borderWidth = 1;
    self.contentView.backgroundColor  = RGBA(1, 1, 1, 0.5);
    
    self.collectionView.backgroundColor  = RGBA(1, 1, 1, 0.5);
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 0;
    currentLayout.minimumInteritemSpacing = 0;
    
    self.collectionView.contentInset = UIEdgeInsetsMake(edge, edge, edge, edge);
    self.collectionView.allowsSelection = YES;
    [currentLayout invalidateLayout];
    
    _contentHeightConstraint.constant = PLAYLIST_INFO_HEIGHT_OF_HEADER + PLAYLIST_INFO_HEIGHT_OF_FOOTER;
    
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self p_fetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dissmis:(void(^)(void))completion {
    _contentHeightConstraint.constant = PLAYLIST_INFO_HEIGHT_OF_HEADER + PLAYLIST_INFO_HEIGHT_OF_FOOTER;// 10 for extend
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

#pragma mark - p_fetchData
- (void)p_fetchData {
    NSArray *datas = nil;
    if (_dataMode == Data_OnlinePlaylist) {
        datas = [[MusicStoreManager sharedManager] fetchAllPlaylist:Data_OnlinePlaylist];
    } else {
        datas = [[MusicStoreManager sharedManager] fetchAllPlaylist:Data_Offline];
    }
    _items = [NSMutableArray arrayWithArray:datas];
    
    [_collectionView performBatchUpdates:^{
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
    }];
    
    int numberOfLines =  MIN((int)_items.count, PLAYLIST_INFO_NUMBER_OF_ITEM);
    
    _contentHeightConstraint.constant = numberOfLines  * PLAYLIST_INFO_HEIGHT_OF_ITEM + 30 + PLAYLIST_INFO_HEIGHT_OF_HEADER + PLAYLIST_INFO_HEIGHT_OF_FOOTER;
    
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
    PlaylistCollectionOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"playlist_cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    PlaylistEntity *entity = [_items objectAtIndex:indexPath.item];
    cell.titleLabel.text = entity.name;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat contentSize = _collectionView.bounds.size.width;
    UIEdgeInsets insets  = _collectionView.contentInset;
    CGSize size = CGSizeMake(contentSize - insets.left - insets.right, PLAYLIST_INFO_HEIGHT_OF_ITEM);
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistEntity *entity = [_items objectAtIndex:indexPath.item];
    
    if (_delegate && [_delegate respondsToSelector:@selector(playlistCollectionViewController:didSelectedPlaylist:)]) {
        [_delegate playlistCollectionViewController:self didSelectedPlaylist:entity];
    }
}

@end
