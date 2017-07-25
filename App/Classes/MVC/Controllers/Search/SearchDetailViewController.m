//
//  SearchDetailViewController.m

//
//  Created by thanhvu on 1/17/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "VideoDetailCollectionViewController.h"
#import "MediaActionViewController.h"
#import "MusicViewController.h"
#import "AlbumDetailViewController.h"
#import "PlaylistCollectionViewController.h"

#import "MediaBaseCell.h"
#import "SongEntity+CoreDataClass.h"
#import "MusicStoreManager.h"

#import "ApiDataObjects.h"
#import "ApiDataProvider.h"

@implementation SearchSectionSetting

+ (id)parseObject:(id)obj {
    SearchSectionSetting *section = [SearchSectionSetting new];
    
    section.title = [obj stringValueKey:@"title"];
    section.numberOfColumns = (int)[obj intValueKey:@"numbercolumn"];
    section.numberOfColumnsExtend = MAX(1, (int)[obj intValueKey:@"numbercolumn_extend"]);
    section.sectionStyle = (SeachSectionStyle)[obj intValueKey:@"sectionstyle"];
    
    return section;
}

- (void)setSectionStyle:(unsigned int)sectionStyle {
    _sectionStyle = sectionStyle;
}

@end

@implementation SearchSectionList

#define SECTION_INVALID_INDEX   -1

+ (id)parseObject:(id)obj {
    if (obj && [NSNull null] != obj && [obj isKindOfClass:[NSArray class]]) {
        
        SearchSectionList *sectionList = [SearchSectionList new];
        sectionList.items = [NSMutableArray array];
        
        for (int i = 0; i < [obj count]; i++) {
            id tmp = [obj objectAtIndex:i];
            
            SearchSectionSetting *section = [SearchSectionSetting parseObject:tmp];
            if (section != nil) {
                [sectionList.items addObject:section];
            }
        }
        return sectionList;
    }
    return nil;
}

- (NSInteger)indexOfSectionStyle:(SeachSectionStyle)style {
    for (int i = 0; i < [self.items count]; i++) {
        SearchSectionSetting *section = [self itemAtIndex:i];
        if (section.sectionStyle == style) {
            return i;
        }
    }
    return SECTION_INVALID_INDEX;
}
@end

@interface SearchDetailViewController()<UICollectionViewDelegate, UICollectionViewDataSource, MediaBaseCellDelegate, MediaActionViewControllerDelegate, PlaylistCollectionViewControllerDelegate> {
    NSInteger _playingIndex;
    float CELL_PADDING;
    
    SearchSectionList *searchSectionList;
}

@property (nonatomic, strong) MediaCollection *mediaCollection;

- (void)p_loadConfiguration;
@end

@implementation SearchDetailViewController

#pragma mark - Load Configuration
- (void)p_loadConfiguration {
    NSArray *sectionSettingData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"search_section_settings" ofType:@"plist"]];
    searchSectionList = [SearchSectionList parseObject:sectionSettingData];
    
    //    [searchSectionList orderField:@"sectionstyle" ascending:YES];
    [_collectionView reloadData];
}

- (void)fetchDataWithKeyword:(NSString *)keyword {
    [self showLoading:YES];
    
    [ApiDataProvider fetchMediaCollection:^(MediaCollection * _Nullable mediaCollection, BOOL success) {
        _mediaCollection = mediaCollection;
        [_collectionView reloadData];
        [self showLoading:NO];
    } withKeyword:keyword];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.title = keyword;
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setups];
    [self p_loadConfiguration];
    
    [self fetchDataWithKeyword:_keyword];
}

- (void)setups {
    CELL_PADDING = 10.0;
    [self setLeftNavButton:Back];
}

#pragma mark - UICollectionView DataSource

- (NSString *)cellIdentifierWithSection:(NSInteger)section {
    if (section == 0) {
        return @"song_cell";
    } else if (section == 1) {
        return @"album_cell";
    } else {
        return @"video_cell";
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return searchSectionList == nil ? 0 : [searchSectionList count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ((!_mediaCollection || !_mediaCollection.songs)) {
        return 0;
    }
    
    SearchSectionSetting *searchSection = [searchSectionList itemAtIndex:section];
    if (searchSection) {
        
    }
    switch (searchSection.sectionStyle) {
        case SearchSectionStyleSong:
            return [_mediaCollection.songs count];
            break;
        case SearchSectionStyleAlbum:
            return [_mediaCollection.albums count];
            break;
        case SearchSectionStyleVideo:
            return [_mediaCollection.videos count];
            break;
        default:
            return 0;
            break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = nil;
    SearchSectionSetting *searchSection = [searchSectionList itemAtIndex:indexPath.section];
    
    NSString *cellIdentifier = nil;
    
    switch (searchSection.sectionStyle) {
        case SearchSectionStyleSong://song
        {
            item = [_mediaCollection.songs itemAtIndex:indexPath.row];
            cellIdentifier = @"song_cell";
        }
            break;
        case SearchSectionStyleAlbum://album
        {
            item = [_mediaCollection.albums itemAtIndex:indexPath.row];
            cellIdentifier = @"album_cell";
        }
            break;
        case SearchSectionStyleVideo://video
        {
            item = [_mediaCollection.videos itemAtIndex:indexPath.row];
            cellIdentifier = @"video_cell";
        }
            break;
        default:
            return nil;
            break;
    }
    MediaBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setItem:item];
    [cell setDelegate:self];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self sizeForItemWithIndexPath:indexPath];
}

- (CGSize)sizeForItemWithIndexPath:(NSIndexPath *)indexPath {
    SearchSectionSetting *searchSection = [searchSectionList itemAtIndex:indexPath.section];
    
    switch (searchSection.sectionStyle) {
        case SearchSectionStyleSong://song
        {
            return CGSizeMake(_collectionView.bounds.size.width, 80);
        }
            break;
        case SearchSectionStyleAlbum://album
        {
            NSInteger cellCount = 2;
            CGFloat w = (_collectionView.bounds.size.width - (cellCount + 1) * CELL_PADDING) / cellCount; // 3 = 2 items/1 row (iphone Only)
            CGFloat h = w + 50.0;
            return CGSizeMake(w, h);
        }
            break;
        case SearchSectionStyleVideo://video
        {
            NSInteger cellCount = 2;
            CGFloat w = (_collectionView.bounds.size.width - (cellCount + 1) * CELL_PADDING) / cellCount;
            CGFloat h = w/2 + 50.0;
            return CGSizeMake(w, h);
        }
            break;
        default:
            break;
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        SearchHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchHeaderView" forIndexPath:indexPath];
        
        SearchSectionSetting *searchSection = [searchSectionList itemAtIndex:indexPath.section];
        
        if (searchSection) {
            headerView.nameLabel.text = LocalizedString(searchSection.title);
        }
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma makr - MediaBaseCellDelegate
- (void)mediaBaseCell:(MediaBaseCell *)cell didSelectedAccessoryView:(MediaAccessoryView *)view {
    MediaActionViewController *vc = [UIStoryboard viewController:SB_MediaActionViewController storyBoard:StoryBoardMain];
    vc.delegate = self;
    vc.mediaView = cell;
    
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    
    SearchSectionSetting *searchSection = [searchSectionList itemAtIndex:indexPath.section];
    
    switch (searchSection.sectionStyle) {
        case SearchSectionStyleSong: {
            Song *song = [_mediaCollection.songs itemAtIndex:indexPath.item];
            vc.mediaTitle = song.name;
        }
            break;
        default:
            break;
    }
    
    [self.navigationController presentViewController:vc animated:NO completion:^{
        [vc setActionsConfigureFile:@"music_song_actions"];
    }];
}

- (void)didSelectedCell:(MediaBaseCell *)cell {
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    SearchSectionSetting *searchSection = [searchSectionList itemAtIndex:indexPath.section];
    switch (searchSection.sectionStyle) {
        case SearchSectionStyleSong: {
            _playingIndex = indexPath.row;
            
            NSMutableArray *audioItems = [NSMutableArray array];
            for (Song *aSong in _mediaCollection.songs.items) {
                [audioItems addObject:[AudioItem initBySongObject:aSong]];
            }
            
            [[AudioPlayer shared] play: audioItems startIndex:indexPath.item];
        }
            break;
        case SearchSectionStyleAlbum: {
            Album *album = [_mediaCollection.albums itemAtIndex:indexPath.item];
            AlbumDetailViewController *vc = [UIStoryboard viewController:SB_AlbumDetailViewController storyBoard:StoryBoardMain];
            vc.albumId = album.identifier;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case SearchSectionStyleVideo: {
            VideoDetailCollectionViewController *vc = (VideoDetailCollectionViewController *)[UIStoryboard viewController:SB_VideoDetailCollectionViewController storyBoard:StoryBoardMain];
            [vc setVideoList:_mediaCollection.videos];
            [vc setSelectedIndex: indexPath.item];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - MediaActionViewControllerDelegate
- (void)mediaActionViewController:(MediaActionViewController *)viewController actionWithView:(UIView *)cell performAction:(MediaActionType)actionType {
    [viewController dissmis:^{
        switch (actionType) {
            case MediaActionAddPlaylist: {
                PlaylistCollectionViewController *vc = [UIStoryboard viewController:SB_PlaylistCollectionViewController storyBoard:StoryBoardMain];
                vc.dataMode = Data_OnlinePlaylist;
                vc.delegate = self;
                [vc setSelectedView:cell];
                
                [self.navigationController presentViewController:vc animated:NO completion:^{
                }];
            }
                break;
            case MediaActionAddFavourite: {
                NSIndexPath *indexPath = [_collectionView indexPathForCell:(id)cell];
                NSObject *obj = [_mediaCollection.songs itemAtIndex:indexPath.row];
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
            case MediaActionDownload: {
                NSIndexPath *indexPath = [_collectionView indexPathForCell:(id)cell];
                Song *song = [_mediaCollection.songs itemAtIndex:indexPath.row];
                NSDictionary *info = [song dictionaryRepresentation];
                [AppActions downloadSongInfo:info];
                
            }
                break;
            case MediaActionSharing: {
                NSIndexPath *indexPath = [_collectionView indexPathForCell:(id)cell];
                Song *song = [_mediaCollection.songs itemAtIndex:indexPath.row];
                
                [AppActions sharingFacebookWithTitle:song.name description:nil link:APPLICATION_ITUNES_STORE_LINK];
            }
                break;
            case MediaActionDelete:
                break;
            case MediaActionRemoveFromPlaylist:
                break;
            default:
                break;
        }
    }];
}

#pragma mark -
- (void)playlistCollectionViewController:(PlaylistCollectionViewController *)viewController didSelectedPlaylist:(PlaylistEntity *)playlist {
    if (viewController && viewController.selectedView) { // songs
        NSIndexPath *indexPath = [_collectionView indexPathForCell:viewController.selectedView];
        Song *song = [_mediaCollection.songs itemAtIndex:indexPath.item];
        
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

@end

@implementation SearchHeaderView

@end
