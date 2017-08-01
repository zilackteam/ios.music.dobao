//
//  MyMusicViewController.m

//
//  Created by thanhvu on 12/13/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "MyMusicViewController.h"
#import "PlaylistSectionReusableView.h"
#import "VideoDetailCollectionViewController.h"

@interface MyMusicViewController ()<MyMusicViewProtocol> {
    
}

@end

@implementation MyMusicViewController

#pragma mark - MyMusicViewProtocol
- (void)registerPlaylistHeaderClass:(__unsafe_unretained Class *)aClass {
    *aClass = [PlaylistSectionReusableView class];
}

- (void)appMyMusic:(AppMyMusicViewController *)viewController didSelectedMenuType:(MenuViewType)type resultList:(BaseList *)list index:(NSInteger)index {
    if (type == MenuViewType_Video) {
        VideoDetailCollectionViewController *vc = [UIStoryboard viewController:SB_VideoDetailCollectionViewController storyBoard:StoryBoardMain];
        vc.selectedIndex = index;
        [vc setList:list];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSString *)cellIdentifierWithMenuType:(MenuViewType)type {
    switch (type) {
        case MenuViewType_Playlist:
            return @"playlist_song_cell";
            break;
        case MenuViewType_Song:
            return @"song_cell";
            break;
        case MenuViewType_SongDownloading:
            return @"song_downloading_cell";
            break;
        case MenuViewType_Video:
            return @"video_cell";
            break;
        default:
            break;
    }
    
    return nil;
}

- (AppMediaActionViewController *)mediaActionViewController {
    return [UIStoryboard viewController:SB_MediaActionViewController storyBoard:StoryBoardMain];
}

- (AppPlaylistCollectionViewController *)playlistCollectionViewController {
    return [UIStoryboard viewController:SB_PlaylistCollectionViewController storyBoard:StoryBoardMain];
}

- (void)appMyMusicCollectionView:(UICollectionView *)collectionView {
    // setup collection view
}

#pragma mark - UIView
- (void)viewDidLoad {
    [super viewDidLoad];
    [self useMainBackgroundOpacity:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
