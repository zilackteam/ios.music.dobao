//
//  AlbumDetailViewController.m

//
//  Created by thanhvu on 12/13/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "AlbumDetailViewController.h"
#import "AlbumHeaderReusableView.h"

@interface AlbumDetailViewController ()<AppAlbumDetailProtocol>
{
}

@end

@implementation AlbumDetailViewController

#pragma mark - View
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self useMainBackgroundOpacity:1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - AppAlbumDetailProtocol
- (AppPlaylistCollectionViewController *)playlistCollectionViewController {
    return [UIStoryboard viewController:SB_PlaylistCollectionViewController storyBoard:StoryBoardMain];
}

- (void)appAlbumDetail:(AppAlbumDetailViewController *)viewController collectionView:(UICollectionView *)collectionView {
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 0;
    currentLayout.minimumInteritemSpacing = 0;
    
    CGFloat edge = 0;
    currentLayout.sectionInset = UIEdgeInsetsMake(edge, edge, edge, edge);
    
    [currentLayout invalidateLayout];
}

- (UIFont *)appAllbumDetailDescriptionFont {
    return [UIFont fontWithName:@"Roboto-Regular" size:16];
}

- (Class)albumHeaderClass {
    return [AlbumHeaderReusableView class];
}

- (AppMediaActionViewController *)mediaActionViewController {
    return [UIStoryboard viewController:SB_MediaActionViewController storyBoard:StoryBoardMain];
}

- (CGFloat)initHeightOfHeader {
    return CGRectGetWidth(self.view.frame) * 0.35 + 20.0f;
}
@end
