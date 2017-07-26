#import "AlbumDetailViewController.h"
#import "AlbumHeaderReusableView.h"
#import "MediaActionViewController.h"
#import "PlaylistCollectionViewController.h"
#import "AppDelegate.h"
#import "MediaBaseCell.h"
#import "APIClient.h"
#import "SongList.h"
#import "SongEntity+CoreDataClass.h"

@interface AlbumDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, MediaBaseCellDelegate, MediaActionViewControllerDelegate, AppPlaylistCollectionDelegate>
{
    __weak IBOutlet UICollectionView *_collectionView;
    NSIndexPath *PlayingItem;
}

@property (strong, nonatomic) Album *album;

@end

@implementation AlbumDetailViewController

#pragma mark - Private
- (void)p_fetchData {
    [self showLoading:YES];
    [[APIClient shared] getListSongOfAlbum:_albumId completion:^(Album *album, BOOL success) {
        
        self.navigationItem.title = album.name;
        self.title  = album.name;
        
        _album = album;
        
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [self showLoading:NO];
        
        [self p_updatePlayingState];
    }];
}

- (void)p_updatePlayingState {
    if (_album) {
        Song *song = nil;
        for (int i = 0; i < _album.songs.count; i++) {
            song = [_album.songs itemAtIndex:i];
            BOOL playing = [[AudioPlayer shared].currentItem identifier] == [song identifier];
            if (playing) {
                MediaBaseCell *cell = nil;
                if (PlayingItem != nil) {
                    MediaBaseCell *cell = (MediaBaseCell *)[_collectionView cellForItemAtIndexPath:PlayingItem];
                    [cell setPlayingState:NO];
                }
                
                PlayingItem = [NSIndexPath indexPathForRow:i inSection:0];
                
                cell = (MediaBaseCell *)[_collectionView cellForItemAtIndexPath:PlayingItem];
                [cell setPlayingState:YES];
                break;
            }
        }
    }
}

#pragma mark - View
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = LocalizedString(@"tlt_album");
    PlayingItem = nil;
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 0;
    currentLayout.minimumInteritemSpacing = 0;
    
    CGFloat edge = 0;
    currentLayout.sectionInset = UIEdgeInsetsMake(edge, edge, edge, edge);
    
    [currentLayout invalidateLayout];
    
    [_collectionView registerClass:[AlbumHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidStartPlayingItem:) name:kNotification_AudioPlayerDidStartPlayingItem object:nil];
    
    [self useMainBackgroundOpacity:1];
    [self setLeftNavButton:Back];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self p_fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_album.songs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MediaBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"song_cell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell setItem:[_album.songs itemAtIndex:indexPath.item]];
    
    if (indexPath == PlayingItem) {
        [cell setPlayingState:YES];
    } else {
        [cell setPlayingState:NO];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_collectionView.bounds.size.width, 80);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        AlbumHeaderReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        
        _album.performer = _album.performer?_album.performer:@"Đàm Vĩnh Hưng";
        [headerView setTitle:_album.name detail:_album.performer description:_album.desc imageUrl:_album.featureUrl?_album.featureUrl:_album.thumbUrl];
        reusableview = headerView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (!_album) {
        return CGSizeZero;
    }
    
    float width = collectionView.bounds.size.width;
    float height = width/2.0 + 100.0f;
    
    CGSize size = [AppUtils boundingRectForString:_album.desc font:[UIFont fontWithName:@"Roboto-Regular" size:16] width:width].size;
    
    if (size.height > 0) {
        height += 25.0f;
    }
    
    return CGSizeMake(width, height + size.height);
}


#pragma mark - MediaBaseCellDelegate
- (void)didSelectedCell:(MediaBaseCell *)cell {
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    
    NSMutableArray *audioItems = [NSMutableArray array];
    for (Song *aSong in _album.songs.items) {
        [audioItems addObject:[AudioItem initBySongObject:aSong]];
    }
    
    [[AudioPlayer shared] play: audioItems startIndex:indexPath.item];
}

- (void)mediaBaseCell:(MediaBaseCell *)cell didSelectedAccessoryView:(MediaAccessoryView *)view {
    MediaActionViewController *vc = [UIStoryboard viewController:SB_MediaActionViewController storyBoard:StoryBoardMain];
    vc.delegate = self;
    vc.mediaView = cell;
    
    NSInteger index = [_collectionView indexPathForCell:cell].item;
    
    Song *song = [_album.songs itemAtIndex:index];
    vc.mediaTitle = song.name;
    id entity = [[MusicStoreManager sharedManager] songByIdentify:song.identifier mode:Data_OnlineFavourite];
    
    if (entity) {
        vc.highlightFavourite = YES;
    }
    
    [self.navigationController presentViewController:vc animated:NO completion:^{
        [vc setActionsConfigureFile:@"album_song_actions"];
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
                Song *song = [_album.songs itemAtIndex:indexPath.item];
                NSDictionary *info = [song dictionaryRepresentation];
                
                [AppActions downloadSongInfo:info];
            }
                break;
            case MediaActionAddFavourite:
            {
                NSObject *obj = [_album.songs itemAtIndex:indexPath.item];
                NSInteger songIdentifier = [[obj valueForKey:@"identifier"] integerValue];
                
                id entity = [[MusicStoreManager sharedManager] songByIdentify:songIdentifier mode:Data_OnlineFavourite];
                if (entity) { // un favourite
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
                Song *song = [_album.songs itemAtIndex:indexPath.row];
                
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
        Song *song = [_album.songs itemAtIndex:indexPath.item];
        
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
    [self p_updatePlayingState];
}

@end
