//
//  MusicViewController.m
//  music.application
//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "MusicViewController.h"
#import "VideoDetailCollectionViewController.h"
#import "AlbumDetailViewController.h"
#import "Song.h"
#import "Album.h"

@interface MusicViewController()<AppMusicViewProtocol>
{
}
@end

@implementation MusicViewController
#pragma mark - AppMusicViewProtocol
- (NSString *)musicCollectionView:(UICollectionView *)collectionView cellIdentifierWithMenuType:(MusicViewType)type {
    switch (type) {
        case MusicViewTypeAlbum:
        case MusicViewTypeSingle:
            return @"album_cell";
        case MusicViewTypeSong:
            return @"song_cell";
        case MusicViewTypeVideo:
            return @"video_cell";
        default:
            return @"";
    }
}

- (NSInteger)refreshTimeInMinutes {
    return TIME_MINUTE_REFRESH;
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self useMainBackgroundOpacity:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (AppPlaylistCollectionViewController *)playlistCollectionViewController {
    return [UIStoryboard viewController:SB_PlaylistCollectionViewController storyBoard:StoryBoardMain];
}

- (AppMediaActionViewController *)mediaActionViewController {
    return [UIStoryboard viewController:SB_MediaActionViewController storyBoard:StoryBoardMain];
}

- (void)musicCollectionView:(UICollectionView *)collectionView {
}

- (void)appMusicView:(AppMusicViewController *)viewController selectedType:(MusicViewType)type list:(BaseList *)list index:(NSInteger)index {
    switch (type) {
        case MusicViewTypeSong:
            break;
        case MusicViewTypeAlbum:
        case MusicViewTypeSingle: {
            Album *album = [list itemAtIndex:index];
            AlbumDetailViewController *vc = [UIStoryboard viewController:SB_AlbumDetailViewController storyBoard:StoryBoardMain];
            vc.albumId = album.identifier;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MusicViewTypeVideo: {
            VideoDetailCollectionViewController *vc = (VideoDetailCollectionViewController *)[UIStoryboard viewController:SB_VideoDetailCollectionViewController storyBoard:StoryBoardMain];
            [vc setList:list];
            [vc setSelectedIndex: index];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
