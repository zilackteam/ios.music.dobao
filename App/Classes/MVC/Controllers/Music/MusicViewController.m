//
//  MusicViewController.m

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "MusicViewController.h"
#import "VideoDetailCollectionViewController.h"
#import "AlbumDetailViewController.h"
#import "MediaActionViewController.h"
#import "PlaylistCollectionViewController.h"

#import "AppUtils.h"
#import "MusicStoreManager.h"
#import "SongEntity+CoreDataClass.h"
#import "Song.h"

#import "MediaBaseCell.h"
#import "LoadMoreReusableView.h"

#import "ApiDataProvider.h"

@interface MusicViewController()<MenuViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MediaBaseCellDelegate, PlaylistCollectionViewControllerDelegate, MediaActionViewControllerDelegate>
{
    float itemSpacing;
    
    NSInteger PlayingItem;
    
    DataPage page;
    
    LoadMoreReusableView *footerView;
}

@property (nonatomic, strong) BaseList *itemList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentHeightConstraint;

- (void)p_updatePlayingState;
- (void)p_fetchData;
- (void)p_reloadData;

@end

@implementation MusicViewController
#pragma mark - Private
- (void)p_updatePlayingState {
    Song *song = nil;
    for (int i = 0; i < _itemList.count; i++) {
        song = [_itemList itemAtIndex:i];
        BOOL playing = [[AudioPlayer shared].currentItem identifier] == [song identifier];
        if (playing) {
            MediaBaseCell *cell = nil;
            if (PlayingItem != INVALID_INDEX && PlayingItem != i) {
                MediaBaseCell *cell = (MediaBaseCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:PlayingItem inSection:0]];
                [cell setPlayingState:NO];
            }
            
            PlayingItem = i;
            cell = (MediaBaseCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:PlayingItem inSection:0]];
            [cell setPlayingState:YES];
            break;
        }
    }
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self useMainBackgroundOpacity:1];
    
    itemSpacing  = 10;
    PlayingItem = INVALID_INDEX;
    
    [self setLeftNavButton:Menu];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidStartPlayingItem:) name:kNotification_AudioPlayerDidStartPlayingItem object:nil];
    
    // default
    page.index = 0;
    page.numberOfPage = 0;
    
    // footer
    [_collectionView registerClass:[LoadMoreReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:@"footer"];
    
    [self updateCollectionViewWithMenuType:_viewType];
    
    [self p_fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateLocalization];
}


- (void)updateLocalization {
    NSString *screenName = @"";
    switch (_viewType) {
        case MusicViewTypeSong: {
            screenName = LocalizedString(@"tlt_songs");
        }
            break;
        case MusicViewTypeAlbum: {
            screenName = LocalizedString(@"tlt_album");
        }
            break;
        case MusicViewTypeSingle: {
            screenName = LocalizedString(@"tlt_single");
        }
            break;
        case MusicViewTypeVideo: {
            screenName = LocalizedString(@"tlt_video");
        }
            break;
        default:
            break;
    }
    
    self.title = screenName;
}

- (void)refreshControlAction {
    [self p_fetchData];
}

- (void)p_fetchData {
/*
    if (page.state == PageStateLoading) {
        return;
    }
*/
    [self showLoading:YES];
    [footerView showLoading];
    
//    page.state = PageStateLoading;
    switch (_viewType) {
        case MusicViewTypeSong: {
            [ApiDataProvider fetchSongList:^(SongList * _Nullable songList, BOOL success) {
                self.itemList = songList;
                [self p_reloadData];
                [self p_updatePlayingState];
            } refreshTimeInMinutes:TIME_MINUTE_REFRESH];
        }
            break;
        case MusicViewTypeAlbum:
        case MusicViewTypeSingle: {
            AlbumType type = (_viewType == MusicViewTypeAlbum)?AlbumTypeNormal:AlbumTypeSingle;
            [ApiDataProvider fetchAlbumListType:type completion:^(AlbumList * _Nullable albumList, BOOL success) {
                self.itemList = albumList;
                [self p_reloadData];
            } refreshTimeInMinutes:TIME_MINUTE_REFRESH];
        }
            break;
        case MusicViewTypeVideo: {
            [ApiDataProvider fetchVideoList:^(VideoList * _Nullable videoList, BOOL success) {
                self.itemList = videoList;
                [self p_reloadData];
            } refreshTimeInMinutes:TIME_MINUTE_REFRESH];
        }
            break;
        default:
            break;
    }
}

- (void)p_reloadData {
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [self showLoading:NO];
    [footerView hideLoading];
}

- (void)updateCollectionViewWithMenuType:(MusicViewType)viewType {
    
    BOOL songType = (viewType == MusicViewTypeSong);
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = songType? 0 : 25;
    currentLayout.minimumInteritemSpacing = itemSpacing;
    
    CGFloat edge = songType ? 0 : itemSpacing;
    currentLayout.sectionInset = UIEdgeInsetsMake(edge, edge, edge, edge);
    
    [currentLayout invalidateLayout];
    [_collectionView reloadData];
}

- (CGSize)sizeForItemWithMenuType:(MusicViewType)type indexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    switch (type) {
        case MusicViewTypeVideo: {
            NSInteger cellCount = 2;
            CGFloat w = (_collectionView.bounds.size.width - (cellCount + 1) * itemSpacing) / cellCount;
            CGFloat h = w/2.0 + 50;
            size = CGSizeMake(w, h);
        }
            break;
        case MusicViewTypeAlbum:
        case MusicViewTypeSingle: {
            NSInteger cellCount = 2;
            CGFloat w = (_collectionView.bounds.size.width - (cellCount + 1) * itemSpacing) / cellCount; // 3 = 2 items/1 row (iphone Only)
            CGFloat h = w + 50.0; //45 = titleLabel.height + detailLabel.height(Phone only)
            size = CGSizeMake(w, h);
        }
            break;
        case MusicViewTypeSong: {
            size = CGSizeMake(_collectionView.bounds.size.width, 80);
        }
            break;
        default:
            size = CGSizeMake(_collectionView.bounds.size.width, 80);
            break;
    }
    return size;
}

- (NSString *)cellIdentifierWithMenuType:(MusicViewType)type {
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

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_itemList)
        return [_itemList count];
    else
        return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self cellIdentifierWithMenuType:_viewType];
    MediaBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    id item = [_itemList itemAtIndex:indexPath.row];
    [cell setItem:item];
    
    if (PlayingItem == indexPath.item) {
        [cell setPlayingState:YES];
    } else {
        [cell setPlayingState:NO];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self sizeForItemWithMenuType:_viewType indexPath:indexPath];
}

#pragma mark - UICollectionViewDatasource

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (_viewType) {
        case MusicViewTypeVideo:{
            VideoDetailCollectionViewController *vc = [UIStoryboard viewController:SB_VideoDetailCollectionViewController storyBoard:StoryBoardMain];
            [vc setSelectedIndex:indexPath.item];
            [vc setVideoList:(VideoList *)self.itemList];
            [self.navigationController pushViewController: vc animated:YES];
        }
            break;
        case MusicViewTypeSong:
            break;
        default:
            break;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {
    return NO;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
    } else if (kind == UICollectionElementKindSectionFooter) {
        footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        reusableview = footerView;
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 80);
}

#pragma mark - ScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
/*
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        [self p_fetchData];
    }
*/
}

#pragma mark - MediaBaseCell Delegate
- (void)didSelectedCell:(MediaBaseCell *)cell {
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    
    switch (_viewType) {
        case MusicViewTypeSong: {
            NSMutableArray *audioItems = [NSMutableArray array];
            for (Song *aSong in _itemList.items) {
                [audioItems addObject:[AudioItem initBySongObject:aSong]];
            }
            
            [[AudioPlayer shared] play: audioItems startIndex:indexPath.row];
        }
            break;
        case MusicViewTypeAlbum:
        case MusicViewTypeSingle: {
            Album *album = [_itemList itemAtIndex:indexPath.row];
            
            AlbumDetailViewController *albumDetailViewController = [UIStoryboard viewController:SB_AlbumDetailViewController storyBoard:StoryBoardMain];
            albumDetailViewController.albumId = album.identifier;
            [self.navigationController pushViewController:albumDetailViewController animated:YES];
        }
            break;
        case MusicViewTypeVideo: {
            VideoDetailCollectionViewController *vc = [UIStoryboard viewController:SB_VideoDetailCollectionViewController storyBoard:StoryBoardMain];
            [vc setSelectedIndex:indexPath.item];
            [vc setVideoList:(VideoList *)self.itemList];
            [self.navigationController pushViewController: vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)mediaBaseCell:(MediaBaseCell *)cell didSelectedAccessoryView:(MediaAccessoryView *)view {
    NSInteger index = [_collectionView indexPathForCell:cell].item;
    MediaActionViewController *vc = [UIStoryboard viewController:SB_MediaActionViewController storyBoard:StoryBoardMain];
    vc.delegate = self;
    vc.mediaView = cell;
    if (_viewType == MusicViewTypeSong) {
        Song *song = [_itemList itemAtIndex:index];
        vc.mediaTitle = song.name;
        
        if ([[MusicStoreManager sharedManager] songByIdentify:song.identifier mode:Data_OnlineFavourite]) {
            vc.highlightFavourite = YES;
        }
    }
    
    [self.navigationController presentViewController:vc animated:NO completion:^{
        [vc setActionsConfigureFile:@"music_song_actions"];
    }];
}

#pragma mark - MediaActionViewControllerDelegate
- (void)mediaActionViewController:(MediaActionViewController *)viewController actionWithView:(UICollectionViewCell *)cell performAction:(MediaActionType)actionType {
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    [viewController dissmis:^{
        switch (actionType) {
            case MediaActionDownload:
            {
                NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
                Song *song = [_itemList itemAtIndex:indexPath.row];
                NSDictionary *info = [song dictionaryRepresentation];
                
                [AppActions downloadSongInfo:info];
            }
                break;
            case MediaActionAddFavourite:
            {
                NSObject *obj = [_itemList itemAtIndex:indexPath.row];
                NSInteger songIdentifier = [[obj valueForKey:@"identifier"] integerValue];
                
                id entity = [[MusicStoreManager sharedManager] songByIdentify:songIdentifier mode:Data_OnlineFavourite];
                if (entity) {
                    [[MusicStoreManager sharedManager] deleteObject:entity];
                } else {
                    id entity = [[MusicStoreManager sharedManager] songOnlineByIdentify:songIdentifier];
                    
                    if (entity) {
                        [entity setValue:@(Data_OnlineFavourite) forKey:@"flag"];
                    } else {
                        entity = [[MusicStoreManager sharedManager] managedObjectClass:[SongEntity class]];
                        [((SongEntity *) entity) setOrderAt:[NSDate date]];
                        [[MusicStoreManager sharedManager] copyPropertiesValueObject:obj toEntity:entity];
                    }
                    
                    [[MusicStoreManager sharedManager] commit];
                }
            }
                break;
            case MediaActionAddPlaylist:
            {
                PlaylistCollectionViewController *vc = [UIStoryboard viewController:SB_PlaylistCollectionViewController storyBoard:StoryBoardMain];
                vc.dataMode = Data_OnlinePlaylist;
                vc.delegate = self;
                [vc setSelectedView:cell];
                [self.navigationController presentViewController:vc animated:NO completion:^{
                }];
            }
                break;
            case MediaActionSharing:
            {
                NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
                Song *song = [_itemList itemAtIndex:indexPath.row];
                
                [AppActions sharingFacebookWithTitle:song.name description:nil link:APPLICATION_ITUNES_STORE_LINK];
            }
                break;
                
            default:
                break;
        }
    }];
}

#pragma mark - PlaylistCollectionViewController Delegate

- (void)playlistCollectionViewController:(PlaylistCollectionViewController *)viewController didSelectedPlaylist:(PlaylistEntity *)playlist {
    if (viewController.selectedView) {
        NSIndexPath *indexPath = [_collectionView indexPathForCell:viewController.selectedView];
        Song *song = [_itemList itemAtIndex:indexPath.row];
        
        SongEntity *entity = [[MusicStoreManager sharedManager] songOnlineByIdentify:song.identifier];
        
        if (entity == nil) {
            entity = [[MusicStoreManager sharedManager] managedObjectClass:[SongEntity class]];
            entity.flag = @(Data_OnlinePlaylist);
        } else if ([[playlist songs] containsObject:entity]) {
            [viewController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        [[MusicStoreManager sharedManager] copyPropertiesValueObject:song toEntity:entity];
        
        [playlist addSongsObject:entity];
        
        [[MusicStoreManager sharedManager] commit];
        [viewController dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

#pragma mark - AudioPlayerListener 
- (void)playerDidStartPlayingItem:(NSNotification *)notification {
    if (_viewType == MusicViewTypeSong) {
        [self p_updatePlayingState];
    }
}

@end
