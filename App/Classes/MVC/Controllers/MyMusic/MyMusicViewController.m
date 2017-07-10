//
//  MyMusicViewController.m

//
//  Created by thanhvu on 12/13/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "MyMusicViewController.h"
#import "MediaActionViewController.h"
#import "PlaylistSectionReusableView.h"
#import "PlaylistCollectionViewController.h"
#import "PlaylistSongCollectionViewCell.h"
#import "DownloadingCollectionCell.h"
#import "VideoDetailCollectionViewController.h"
#import "ZLDownloadManager.h"

#import "MenuView.h"
#import "Song.h"
#import "Video.h"
#import "MusicStoreManager.h"
#import "SongEntity+CoreDataClass.h"
#import "AlbumEntity+CoreDataClass.h"
#import "PlaylistEntity+CoreDataClass.h"
#import "VideoEntity+CoreDataClass.h"
#import "ZLTextField.h"
#import "ZLRoundButton.h"

#import "MediaBaseCell.h"
#import "AppActions.h"

@interface MyMusicViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, MenuViewDelegate, MediaBaseCellDelegate, MediaActionViewControllerDelegate, PlaylistCollectionViewControllerDelegate, PlaylistSectionReusableViewDelegate, ZLDownloadManagerDelegate, DownloadingViewCellDelegate>
{
    NSInteger sectionSelected;
    
    NSIndexPath *PlayingItem;
    __weak IBOutlet ZLTextField *playlistInputTextField;
    __weak IBOutlet ZLRoundButton *playlistCreateButton;
}

@property (nonatomic, assign) MenuViewType viewType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playlistCreateViewHeightConstraint;

@property (strong, nonatomic) NSMutableArray *items;

- (void)p_updatePlayingState;

- (void)p_updateCollectionViewWithMenuType:(MenuViewType)viewType;

- (void)p_fetchData;

@end

@implementation MyMusicViewController
@synthesize collectionView = _collectionView;
@synthesize menuView = _menuView;

#pragma mark - Private
- (void)p_updatePlayingState {
    if (_viewType == MenuViewType_Song) {
        for (int i = 0; i < _items.count; i++) {
            BOOL playing = [[AudioPlayer shared].currentItem identifier] == [[(SongEntity *)_items[i] identifier] integerValue];
            if (playing) {
                MediaBaseCell *cell = nil;
                if (PlayingItem != nil) {
                    MediaBaseCell *cell = (MediaBaseCell *)[_collectionView cellForItemAtIndexPath:PlayingItem];
                    if (cell) {
                        [cell setPlayingState:NO];
                    }
                }
                
                PlayingItem = [NSIndexPath indexPathForRow:i inSection:0];
                
                cell = (MediaBaseCell *)[_collectionView cellForItemAtIndexPath:PlayingItem];
                [cell setPlayingState:YES];
                break;
            }
        }
    } else if (_viewType == MenuViewType_Playlist) {
        if (sectionSelected != INVALID_INDEX) {
            PlaylistEntity *playlist = [_items objectAtIndex:sectionSelected];
            
            for (int i = 0; i < [playlist.songs count]; i++) {
                SongEntity *song = [[playlist.songs allObjects] objectAtIndex:i];
                
                BOOL playing = [[AudioPlayer shared].currentItem identifier] == [song.identifier integerValue];
                if (playing) {
                    MediaBaseCell *cell = nil;
                    if (PlayingItem != nil) {
                        MediaBaseCell *cell = (MediaBaseCell *)[_collectionView cellForItemAtIndexPath:PlayingItem];
                        if (cell) {
                            [cell setPlayingState:NO];
                        }
                    }
                    
                    PlayingItem = [NSIndexPath indexPathForRow:i inSection:sectionSelected];
                    
                    cell = (MediaBaseCell *)[_collectionView cellForItemAtIndexPath:PlayingItem];
                    [cell setPlayingState:YES];
                    break;
                }
            }
        }
    }
}

- (void)p_fetchData {
    NSArray *datas = nil;
    switch (_viewType) {
        case MenuViewType_Song:
            if (_mode == MyMusicMode_Online) {
                datas = [[MusicStoreManager sharedManager] fetchAllSong:Data_OnlineFavourite];
            } else {
                datas = [[MusicStoreManager sharedManager] fetchAllSong:Data_Offline];
                NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"orderAt"
                                                                             ascending:NO];
                datas = [datas sortedArrayUsingDescriptors:@[descriptor]];
            }
            break;
        case MenuViewType_Album:
            if (_mode == MyMusicMode_Online) {
                datas = [[MusicStoreManager sharedManager] fetchAllAlbum:Data_OnlineFavourite];
            }
            break;
        case MenuViewType_Video:
            if (_mode == MyMusicMode_Online) {
                datas = [[MusicStoreManager sharedManager] fetchAllVideo:Data_OnlineFavourite];
            }
            break;
        case MenuViewType_Playlist:
            if (_mode == MyMusicMode_Online) {
                datas = [[MusicStoreManager sharedManager] fetchAllPlaylist:Data_OnlinePlaylist];
            } else {
                datas = [[MusicStoreManager sharedManager] fetchAllPlaylist:Data_Offline];
            }
            break;
        case MenuViewType_SongDownloading:
            datas = [[[ZLDownloadManager shared] tasks] allObjects];
            break;
        default:
            break;
    }
    
    _items = [NSMutableArray arrayWithArray:datas];
    
    [self p_updateCollectionViewWithMenuType:_viewType];
    
    [_collectionView reloadData];
    
    [self p_updatePlayingState];
    [playlistInputTextField setStatus:ZLTextFieldNormal];
    [playlistCreateButton setNeedsDisplay];
}

- (IBAction)createPlaylistButtonSelected:(id)sender {
    NSString *name = playlistInputTextField.text;
    NSString *msgerror = nil;
    if (name) {
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSInteger length = [name length];
        if (length == 0) {
            msgerror = LocalizedString(@"msg_input_name");
        } else if (length > 255) {
            msgerror = LocalizedString(@"msg_error_name_too_long");
        } else if (length < 2) {
            msgerror = LocalizedString(@"msg_error_name_too_short");
        }
    }
    
    if (msgerror != nil) {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil
                                                           message:msgerror
                                                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alerView show];
        
        return;
    }
    
    PlaylistEntity *entity = [[MusicStoreManager sharedManager] managedObjectClass:[PlaylistEntity class]];
    entity.name = name;
    entity.flag = (_mode == MyMusicMode_Online)?@(Data_OnlinePlaylist):@(Data_Offline);
    
    [[MusicStoreManager sharedManager] commit];
    
    playlistInputTextField.text = @"";
    
    [self hideKeyboard];
    
    [_collectionView performBatchUpdates:^{
        [_items insertObject:entity atIndex:0];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
    }];
//    [self p_fetchData];
}

#pragma mark - UIView
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateLocalization {
    if (_mode == MyMusicMode_Online) {
        self.title = LocalizedString(@"tlt_favourite_music");
    } else {
        self.title = LocalizedString(@"tlt_download");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self useMainBackgroundOpacity:1];
    
    [self updateLocalization];
    [self setLeftNavButton:Menu];
    
    // setup menu
    [_menuView layoutIfNeeded];
    _menuView.delegate = self;
    if (_mode == MyMusicMode_Online) {
//        [_menuView setTypes:MenuViewType_Song, MenuViewType_Playlist, MenuViewType_Album, MenuViewType_Video, nil];
        [_menuView setTypes:MenuViewType_Song, MenuViewType_Playlist, MenuViewType_Video, nil];
    } else {
        [_menuView setTypes:MenuViewType_Song, MenuViewType_Playlist, MenuViewType_SongDownloading, nil];
    }
    
    [_collectionView registerClass:[PlaylistSectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidStartPlayingItem:) name:kNotification_AudioPlayerDidStartPlayingItem object:nil];
    
    _playlistCreateViewHeightConstraint.constant = 1.0f;
    
    [self.view layoutIfNeeded];
    
    [[ZLDownloadManager shared] setDelegate:self];
    sectionSelected = INVALID_INDEX;
    [_menuView setSelectedType:MenuViewType_Song];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self p_fetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)sizeForItemWithMenuType:(MenuViewType)type indexPath:(NSIndexPath *)indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGSize size;
    if (type == MenuViewType_Video) {
        NSInteger cellCount = 2;
        CGFloat w = (_collectionView.bounds.size.width - (cellCount + 1) * 10) / cellCount;
        CGFloat h = w/2.0 + 50;
        size = CGSizeMake(w, h);
    } else {
        float cellWidth = screenWidth;
        size = CGSizeMake(cellWidth, 80);
    }
    
    return size;
}

- (void)p_updateCollectionViewWithMenuType:(MenuViewType)viewType {
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    float edge = 0.0f;
    collectionViewLayout.minimumInteritemSpacing = 0;
    
    switch (viewType) {
        case MenuViewType_Song: {
            collectionViewLayout.minimumLineSpacing = 0.0;
        }
            break;
        case MenuViewType_Playlist: {
            collectionViewLayout.minimumLineSpacing = 0.0;
        }
            break;
        case MenuViewType_Album:
        case MenuViewType_Video: {
            collectionViewLayout.minimumLineSpacing = 25.0;
            edge = 10.0f;
        }
            break;
        default:
            break;
    }
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(edge, edge, edge, edge);
    [collectionViewLayout invalidateLayout];
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

#pragma mark - MenuView Delegate

- (void)menuView:(MenuView *)view willSelectedType:(MenuViewType)type {
    _viewType = type;
    [_menuView setTouchDisable:YES];
    [self.view endEditing:YES];
    PlayingItem = nil;
    switch (type) {
        case MenuViewType_Playlist:
            _playlistCreateViewHeightConstraint.constant = 60.0f;
            break;
        default:
            _playlistCreateViewHeightConstraint.constant = 0.0f;
            break;
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)menuView:(MenuView *)view didSelectedType:(MenuViewType)type {
    _items = nil;
    sectionSelected = INVALID_INDEX;
    [_collectionView reloadData];
    
    [self p_fetchData];
    
    [_menuView setTouchDisable:NO];
}

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_viewType == MenuViewType_Playlist) {
        if (!_items) {
            return 0;
        }
        return [_items count];
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_viewType == MenuViewType_Playlist) {
        if (!_items) {
            return 0;
        }
        
        if (section != sectionSelected) {
            return 0;
        } else {
            PlaylistEntity *playlist = [_items objectAtIndex:section];
            return [playlist.songs count];
        }
    }
    return [_items count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = [self cellIdentifierWithMenuType:_viewType];
    
    if (_viewType == MenuViewType_SongDownloading) {
        DownloadingCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        DownloadTaskObject *task = [_items objectAtIndex:indexPath.row];
        [cell setTaskObject:task];
        [cell setDelegate:self];
        return cell;
    } else {
        MediaBaseCell *cell = (MediaBaseCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.delegate = self;
        id item = nil;// = [_items objectAtIndex:indexPath.row];
        
        if (_viewType == MenuViewType_Playlist) {
            PlaylistEntity *playlist = [_items objectAtIndex:indexPath.section];
            item = [[playlist.songs allObjects] objectAtIndex:indexPath.row];
            
            [(PlaylistSongCollectionViewCell *)cell setItemNo: indexPath.row + 1];
        } else {
            item = [_items objectAtIndex:indexPath.row];
        }
        
        [cell setValue:item];
        
        if (indexPath == PlayingItem) {
            [cell setPlayingState:YES];
        } else {
            [cell setPlayingState:NO];
        }
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self sizeForItemWithMenuType:_viewType indexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (_viewType == MenuViewType_Playlist) {
        if (kind == UICollectionElementKindSectionHeader) {
            PlaylistSectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
            id item = [_items objectAtIndex:indexPath.section];
            [headerView setValue:item];
            headerView.delegate = self;
            [headerView setSection:indexPath.section];
            reusableview = headerView;
        } else if (kind == UICollectionElementKindSectionFooter) {
/*
            if (_viewType == MyMusicType_Playlist) {
                PlaylistFooterReusableView *footerView = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"playlist_footer" forIndexPath:indexPath];
                
                reusableview = footerView;
            }
*/
        }
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (_viewType == MenuViewType_Playlist) {
        return CGSizeMake(collectionView.bounds.size.width, 80.);
    } else {
        return CGSizeZero;
    }
}

#pragma mark - MediaBaseCell Delegate
- (void)didSelectedCell:(MediaBaseCell *)cell {
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    if (_viewType == MenuViewType_Song) {
        NSMutableArray *audioItems = [NSMutableArray array];
        for (SongEntity *aSong in _items) {
            [audioItems addObject:[AudioItem initBySongObject:aSong]];
        }
        
        [[AudioPlayer shared] play: audioItems startIndex:indexPath.item];
    } else if (_viewType == MenuViewType_Playlist) {
        PlaylistEntity *playlist = [_items objectAtIndex:indexPath.section];
        
        NSMutableArray *audioItems = [NSMutableArray array];
        for (SongEntity *aSong in playlist.songs) {
            [audioItems addObject:[AudioItem initBySongObject:aSong]];
        }
        
        [[AudioPlayer shared] play: audioItems startIndex:indexPath.item];
    } else if (_viewType == MenuViewType_Video) {
        VideoDetailCollectionViewController *vc = [UIStoryboard viewController:SB_VideoDetailCollectionViewController storyBoard:StoryBoardMain];
        vc.selectedIndex = indexPath.item;
        
        VideoList *videoList = [[VideoList alloc] init];
        for (int i = 0; i < [_items count]; i++) {
            id object = [MusicStoreManager objectClass:[Video class] fromEntity:[_items objectAtIndex:i]];
            [videoList.items addObject:object];
        }
        
        [vc setVideoList:videoList];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)mediaBaseCell:(MediaBaseCell *)cell didSelectedAccessoryView:(MediaAccessoryView *)view {
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    NSInteger index = indexPath.item;
    
    MediaActionViewController *vc = [UIStoryboard viewController:SB_MediaActionViewController storyBoard:StoryBoardMain];
    vc.delegate = self;
    vc.mediaView = cell;
    
    NSString *configurationFile = nil;
    switch (_viewType) {
        case MenuViewType_Song: {
            SongEntity *song = [_items objectAtIndex:index];
            vc.mediaTitle = song.name;
            configurationFile = (_mode == MyMusicMode_Online)?@"online_song_actions":@"offline_song_actions";
            if (_mode == MyMusicMode_Online) {
                vc.highlightFavourite = YES;
            }
        }
            break;
        case MenuViewType_Playlist: {
            PlaylistEntity *playlist = [_items objectAtIndex:indexPath.section];
            SongEntity *item = [[playlist.songs allObjects] objectAtIndex:index];
            vc.mediaTitle = item.name;
            configurationFile = (_mode == MyMusicMode_Online)?@"online_playlist_actions":@"offline_playlist_actions";
        }
            break;
        default:
            break;
    }
    
    [self.navigationController presentViewController:vc animated:NO completion:^{
        [vc setActionsConfigureFile:configurationFile];
    }];
}

#pragma mark - SectionBaseVewDelegate
- (void)sectionBaseView:(SectionReusableBaseView *)view didSelectedAccessoryView:(MediaAccessoryView *)accessoryView atSection:(NSInteger)section {
    if (_viewType == MenuViewType_Playlist) {
        MediaActionViewController *vc = [UIStoryboard viewController:SB_MediaActionViewController storyBoard:StoryBoardMain];
        vc.delegate = self;
        PlaylistEntity *item = [_items objectAtIndex:section];
        vc.mediaTitle = item.name;
        vc.mediaView = view;
        
        [self.navigationController presentViewController:vc animated:NO completion:^{
            [vc setActionsConfigureFile:(_mode == MyMusicMode_Online)?@"online_playlist_actions":@"offline_playlist_actions"];
        }];
    }
}

#pragma mark - PlaylistSectionReusableViewDelegate
- (void)playlistSectionResableView:(PlaylistSectionReusableView *)view selectedObject:(id<BaseObject>)object {
    if (_viewType == MenuViewType_Playlist) {
        NSInteger section = [_items indexOfObject:object];
        
        if (section == sectionSelected) {
            sectionSelected = INVALID_INDEX;
            [_collectionView performBatchUpdates:^{
                [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
            } completion:^(BOOL finished) {
            }];
        } else {
            if (sectionSelected != INVALID_INDEX) {
                NSInteger oldSectionSelection = sectionSelected;
                sectionSelected = INVALID_INDEX;
                
                [_collectionView performBatchUpdates:^{
                    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:oldSectionSelection]];
                } completion:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        sectionSelected = section;
                        [_collectionView performBatchUpdates:^{
                            [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
                        } completion:^(BOOL finished) {
                            [self p_updatePlayingState];
                        }];
                    });
                }];
            } else {
                sectionSelected = section;
                [_collectionView performBatchUpdates:^{
                    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionSelected]];
                } completion:^(BOOL finished) {
                    [self p_updatePlayingState];
                }];
            }
        }
    }
}

#pragma mark - MediaActionViewControllerDelegate
- (void)mediaActionViewController:(MediaActionViewController *)viewController actionWithView:(UIView *)view performAction:(MediaActionType)actionType {
    [viewController dissmis:^{
        switch (actionType) {
            case MediaActionDownload:// only song
            {
                UICollectionViewCell *cell = (UICollectionViewCell *)view;
                NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
                SongEntity *song = [_items objectAtIndex:indexPath.row];
                
                NSDictionary *info = [song dictionaryRepresentation];
                [AppActions downloadSongInfo:info];
            }
                break;
            case MediaActionAddFavourite: // song
            {
                if (_viewType == MenuViewType_Song) {
                    
                    NSIndexPath *indexPath = [_collectionView indexPathForCell:(id)view];
                    SongEntity *item = [_items objectAtIndex:indexPath.row];
                    
                    [_collectionView performBatchUpdates:^{
                        [_items removeObject:item];
                        [_collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                    } completion:^(BOOL finished) {
                        
                        if ([item.playlists count] != 0) {
                            item.flag = @(Data_OnlinePlaylist);
                        } else {
                            [[MusicStoreManager sharedManager] deleteObject:item];
                        }
                        [[MusicStoreManager sharedManager] commit];
                    }];
                }
            }
                break;
            case MediaActionDelete: // song or playlist
            {
                if (_viewType == MenuViewType_Playlist) {
                    if ([view isKindOfClass:[PlaylistSectionReusableView class]]) { // playlist
                        SectionReusableBaseView *baseView = (SectionReusableBaseView *)view;
                        NSInteger selecteSection = baseView.section;
                        
                        if (selecteSection == sectionSelected) {
                            sectionSelected = INVALID_INDEX;
                        }
                        
                        PlaylistEntity *playlist = [_items objectAtIndex:selecteSection];
                        
                        [playlist.songs enumerateObjectsUsingBlock:^(SongEntity * _Nonnull obj, BOOL * _Nonnull stop) {
                            if ([obj.flag intValue] == Data_OnlinePlaylist) { // remove only onlineplaylist/ not for favourite
                                [playlist removeSongsObject:obj];
                            }
                        }];
                        
                        [_collectionView performBatchUpdates:^{
                            [_items removeObject:playlist];
                            [_collectionView deleteSections:[NSIndexSet indexSetWithIndex:selecteSection]];
                        } completion:^(BOOL finished) {
                            [[MusicStoreManager sharedManager] deleteObject:playlist];
                            [[MusicStoreManager sharedManager] commit];
                            [_collectionView reloadData];
                        }];
                    } else if ([view isKindOfClass:[PlaylistSongCollectionViewCell class]]) { // song in playlist
                        
                        id cell = view;
                        NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
                        
                        PlaylistEntity *playlist = [_items objectAtIndex:indexPath.section];
                        SongEntity *song = [[playlist.songs allObjects] objectAtIndex:indexPath.item];
                        
                        [_collectionView performBatchUpdates:^{
                            [playlist removeSongsObject:song];
                            [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
                        } completion:^(BOOL finished) {
                            [[MusicStoreManager sharedManager] commit];
                        }];
                    }
                } else if (_viewType == MenuViewType_Song) {
                    NSIndexPath *indexPath = [_collectionView indexPathForCell:(id)view];
                    SongEntity *song = [_items objectAtIndex:indexPath.item];
                    
                    [_collectionView performBatchUpdates:^{
                        [_items removeObject:song];
                        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    } completion:^(BOOL finished) {
                        [[MusicStoreManager sharedManager] deleteObject:song];
                        [[MusicStoreManager sharedManager] commit];
                    }];
                }
            }
                break;
            case MediaActionAddPlaylist:
            {
                PlaylistCollectionViewController *vc = [UIStoryboard viewController:SB_PlaylistCollectionViewController storyBoard:StoryBoardMain];
                vc.dataMode = (_mode == MyMusicMode_Online)?Data_OnlinePlaylist:Data_Offline;
                [vc setSelectedView:view];
                vc.delegate = self;
                
                [self.navigationController presentViewController:vc animated:NO completion:^{
                }];
            }
                break;
            case MediaActionSharing:
            {
                UICollectionViewCell *cell = (UICollectionViewCell *)view;
                NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
                SongEntity *song = [_items objectAtIndex:indexPath.row];
                
                [AppActions sharingFacebookWithTitle:song.name description:nil link:APPLICATION_ITUNES_STORE_LINK];
            }
                break;
            default:
                break;
        }
    }];
}

#pragma mark -
#pragma mark - ZLDownloadManager Delegate
- (void)downloadManger:(ZLDownloadManager *)downloadManager finishDownloadWithTask:(DownloadTaskObject *)task filePath:(NSURL *)filePath {
    if (_viewType == MenuViewType_SongDownloading) {
        [self p_removeTask:task];
    } else if (_viewType == MenuViewType_Song && _mode == MyMusicMode_Offline) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *datas = [[MusicStoreManager sharedManager] fetchAllSong:Data_Offline];
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"orderAt"
                                                                         ascending:NO];
            datas = [datas sortedArrayUsingDescriptors:@[descriptor]];
            
            _items = [NSMutableArray arrayWithArray:datas];
            [_collectionView performBatchUpdates:^{
                [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathWithIndex:0]]];
            } completion:^(BOOL finished) {
            }];
        });
    }
}

- (void)downloadManger:(ZLDownloadManager *)downloadManager errorWithTask:(DownloadTaskObject *)task {
    if (_viewType == MenuViewType_SongDownloading) {
        [self p_removeTask:task];
    }
}

- (void)p_removeTask:(DownloadTaskObject *)taskObject {
    if (taskObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger index = [_items indexOfObject:taskObject];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            if ([_collectionView cellForItemAtIndexPath:indexPath]) {
                [_collectionView performBatchUpdates:^{
                    [_items removeObjectAtIndex:index];
                    [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
                } completion:^(BOOL finished) {
                }];
            }
        });
    }
}

#pragma mark - DownloadingCollectionCell Delegate
- (void)downloadingViewCell:(id)downloadingViewCell p_removeTask:(DownloadTaskObject *)task {
    //    [self p_removeTask:task];
    [[ZLDownloadManager shared] removeTasks:task];
}

#pragma mark - PlaylistCollectionViewController Delegate
- (void)playlistCollectionViewController:(PlaylistCollectionViewController *)viewController didSelectedPlaylist:(PlaylistEntity *)playlist {
    if (viewController.selectedView) {
        SongEntity *entity = nil;
        NSIndexPath *indexPath = [_collectionView indexPathForCell:viewController.selectedView];
        
        if (_viewType == MenuViewType_Song) {
            entity = [_items objectAtIndex:indexPath.item];
            
        } else if (_viewType == MenuViewType_Playlist) {
            PlaylistEntity *playlist = [_items objectAtIndex:indexPath.section];
            entity = [[playlist.songs allObjects] objectAtIndex:indexPath.item];
        }
        
        [playlist addSongsObject:entity];
        [[MusicStoreManager sharedManager] commit];
        [viewController dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

#pragma mark - AudioPlayerListener
- (void)playerDidStartPlayingItem:(NSNotification *)notification {
    [self p_updatePlayingState];
}
@end
