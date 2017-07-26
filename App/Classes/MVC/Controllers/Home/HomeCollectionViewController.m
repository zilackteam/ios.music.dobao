//
//  HomeCollectionViewController.m
//  music.application
//
//  Created by thanhvu on 3/18/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeCollectionViewController.h"
#import "MusicViewController.h"
#import "VideoDetailCollectionViewController.h"
#import "AlbumDetailViewController.h"
#import "CommentViewController.h"

#import "HomeItemCell.h"
#import "HomeVideoCell.h"
#import "HomeSectionHeaderReusableView.h"
#import "HomeSectionFooterReusableView.h"
#import "HomeStatusView.h"

#import "SongCollectionCell.h"

#import "ApiDataProvider.h"
#import "APIClient.h"
#import "AlbumList.h"
#import "AppDelegate.h"

#import "HomeCollectionManager.h"


#define LIMIT_VIDEO                         6
#define LIMIT_ALBUM                         9
#define LIMIT_SONG                          9
#define CONTENT_REFRESH_TIME_IN_MINUTES     60 * 6

#pragma mark - HomeCollectionViewController Implement
@interface HomeCollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, HomeSectionFotterReusableViewDelegate, MediaBaseCellDelegate, HomeStatusViewDelegate> {
    SectionSettingList *sectionSettingList;
    
    BOOL screenLoading;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTopConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) SectionItemDictionary *sectionItemDictionary;
@property (strong, nonatomic) Post *lastestPost;

// load configuration
- (void)p_loadConfiguration;
// load data
- (void)p_fetchAllData;
- (void)p_fetchDataWithStyle:(SectionStyle)style;
// update section
- (void)p_updateSectionStyle:(SectionStyle)style withState:(FooterState)state;
- (SectionSetting *)p_settingWithStyle:(SectionStyle)style;

@end

@implementation HomeCollectionViewController

#pragma mark - Settings Value
- (SectionSetting *)p_settingWithStyle:(SectionStyle)style {
    return [sectionSettingList sectionByStyle:style];
}

- (void)p_updateSectionStyle:(SectionStyle)style withState:(FooterState)state {
    [sectionSettingList updateState:state forSectionStyle:style];
}

#pragma mark - View Load
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setLeftNavButton:Menu];
    screenLoading = YES;
//    self.view.backgroundColor = RGB(34, 34, 34);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self useMainBackgroundOpacity:1];
    
//    self.collectionView.scrollEnabled = NO;
    self.collectionView.backgroundView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, APPLICATION_MINI_PLAYER_HEIGHT, 0);
    self.collectionView.alwaysBounceVertical = NO;
//    self.collectionView.bounces = NO;
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 10;
    currentLayout.minimumInteritemSpacing = 10;
    [currentLayout invalidateLayout];
    
    // header
    [_collectionView registerClass:[HomeSectionHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:@"header"];
    // footer
    [_collectionView registerClass:[HomeSectionFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:@"footer"];
    
    _sectionItemDictionary = [[SectionItemDictionary alloc] init];
    
    [self.view layoutIfNeeded];
    
    { // title view
        UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 24)];
        titleView.contentMode = UIViewContentModeScaleAspectFit;
        titleView.clipsToBounds = YES;
        titleView.image = [UIImage imageNamed:@"img_logo_artist"];
        titleView.transform = CGAffineTransformMakeScale(0, 0);
        
        [UIView animateWithDuration:0.5 animations:^{
            titleView.transform = CGAffineTransformIdentity;
        }];
        self.navigationItem.titleView = titleView;
    }
    
    [self updateLocalization];
    [self p_loadConfiguration];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // don't remove this line, i'll crash.
    [_collectionView reloadData];
    
    [self updateLatestPost];
}

- (void)updateLocalization {
//    self.title = LocalizedString(@"tlt_home");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionView Refetch
- (void)refreshControlAction {
    [self p_fetchAllData];
}

#pragma mark - Load Configuration
- (void)p_loadConfiguration {
    NSArray *sectionSettingData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_section_settings" ofType:@"plist"]];
    sectionSettingList = [SectionSettingList parseObject:sectionSettingData];
    
    [_collectionView reloadData];
}

#pragma mark - HomeStatusViewDelegate
- (void)homeStatusView:(HomeStatusView *)homeStatusView performAction:(int)action {
    if (action == 1) {
        [_collectionView setContentOffset:CGPointMake(0, CGRectGetHeight(self.view.frame)) animated:YES];
    } else {
        if (_lastestPost) {
            CommentViewController *vc = (CommentViewController *)[UIStoryboard viewController:SB_CommentViewControler storyBoard:StoryBoardSocial];
            vc.post = _lastestPost;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)setLastestPost:(Post *)lastestPost {
    _lastestPost = lastestPost;
    [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[sectionSettingList indexOfSectionStyle:SectionStyleStatus] inSection:0]]];
}

#pragma mark - Load Datas
- (void)p_fetchAllData {
    // load data
    [self p_fetchDataWithStyle:SectionStyleVideo];
    [self p_fetchDataWithStyle:SectionStyleAlbum];
    [self p_fetchDataWithStyle:SectionStyleSong];
}

- (void)p_fetchDataWithStyle:(SectionStyle)style {
    
    NSInteger index = [sectionSettingList indexOfSectionStyle:style];
    if (index == SECTION_INVALID_INDEX) {
        NSAssert(index != SECTION_INVALID_INDEX, @"invalid section index");
        return;
    }
    
    switch (style) {
        case SectionStyleVideo: { // video
            [ApiDataProvider fetchVideoList:^(VideoList * _Nullable videoList, BOOL success) {
                [self p_updateSectionStyle:SectionStyleVideo withState:FooterState_Narrow];
                if (success && videoList) {
                    if (!_sectionItemDictionary) {
                        _sectionItemDictionary = [[SectionItemDictionary alloc] init];
                    }
                    
                    [_collectionView performBatchUpdates:^{
                        [_sectionItemDictionary setValue:[videoList subList:0 length:LIMIT_VIDEO] forStyle:SectionStyleVideo];
                        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:index]];
                    } completion:^(BOOL finished) {
                    }];
                }
            } refreshTimeInMinutes:CONTENT_REFRESH_TIME_IN_MINUTES limit:LIMIT_VIDEO];
        }
            break;
        case SectionStyleAlbum: { // album
            [ApiDataProvider fetchAlbumListType:AlbumTypeNormal completion:^(AlbumList * _Nullable albumList, BOOL success) {
                [self p_updateSectionStyle:SectionStyleAlbum withState:FooterState_Narrow];
                if (success && albumList) {
                    if (!_sectionItemDictionary) {
                        _sectionItemDictionary = [[SectionItemDictionary alloc] init];
                    }
                    [_collectionView performBatchUpdates:^{
                        [_sectionItemDictionary setValue:[albumList subList:0 length:LIMIT_ALBUM] forStyle:SectionStyleAlbum];
                        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:index]];
                    } completion:^(BOOL finished) {
                    }];
                }
            } refreshTimeInMinutes:CONTENT_REFRESH_TIME_IN_MINUTES limit:LIMIT_ALBUM];
        }
            break;
        case SectionStyleSong: { // song
            [ApiDataProvider fetchSongList:^(SongList * _Nullable songList, BOOL success) {
                [self p_updateSectionStyle:SectionStyleSong withState:FooterState_Narrow];
                if (success && songList) {
                    if (!_sectionItemDictionary) {
                        _sectionItemDictionary = [[SectionItemDictionary alloc] init];
                    }
                    [_collectionView performBatchUpdates:^{
                        [_sectionItemDictionary setValue:[songList subList:0 length:LIMIT_SONG] forStyle:SectionStyleSong];
                        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:index]];
                    } completion:^(BOOL finished) {
                    }];
                }
            } refreshTimeInMinutes:CONTENT_REFRESH_TIME_IN_MINUTES limit:LIMIT_SONG];
        }
            break;
        default:
            break;
    }
}

- (void)updateLatestPost {
    [[APIClient shared] getLatestPostWithCompletion:^(Post *aPost, BOOL success) {
        self.lastestPost = aPost;
        if (success) {
        } else {
        }
        self.collectionView.scrollEnabled = YES;
        [self p_fetchAllData];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (!sectionSettingList) {
        return 0;
    }
    return sectionSettingList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    SectionSetting *sectionSetting = [sectionSettingList itemAtIndex:section];
    if (sectionSetting.sectionStyle == SectionStyleStatus) {
        return 1;
    }
    
    FooterState state = sectionSetting.state;
    BaseList *list = [_sectionItemDictionary objectWithStyle:sectionSetting.sectionStyle];
    if (!list || state == FooterState_Loading) {
        return 0;
    } else {
        if (state == FooterState_Narrow) {
            return MIN(sectionSetting.numberOfColumns, [list count]);
        } else {
            return [list count];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MediaBaseCell *cell = nil;
    SectionSetting *sectionSetting = [sectionSettingList itemAtIndex:indexPath.section];
    
    switch (sectionSetting.sectionStyle) {
        case SectionStyleVideo:
            cell = (HomeVideoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"video_cell" forIndexPath:indexPath];
            break;
        case SectionStyleSong:
        case SectionStyleAlbum:
            cell = (HomeItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"item_cell" forIndexPath:indexPath];
            break;
        case SectionStyleStatus:
        {
            HomeStatusView *statusCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"status_cell" forIndexPath:indexPath];
            if (_lastestPost) {
                [statusCell hideLoading];
            } else {
                [statusCell showLoading];
            }
            [statusCell setDelegate:self];
            [statusCell setPost:_lastestPost];
            return statusCell;
        }
            break;
        default:
            break;
    }
    
    cell.delegate = self;
    
    BaseList *obj = [_sectionItemDictionary objectWithStyle:sectionSetting.sectionStyle];
    id<MediaItem> item = [obj itemAtIndex:indexPath.item];
    [cell setItem:item useFeature:YES];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    SectionSetting *setting = [sectionSettingList itemAtIndex:indexPath.section];
    if (setting.sectionStyle == SectionStyleStatus) {
        return nil;
    }
    
    if (kind == UICollectionElementKindSectionHeader) {
        HomeSectionHeaderReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"forIndexPath:indexPath];
        [headerView setDelegate:self];
        [headerView setSection:indexPath.section];
        headerView.titleLabel.text = [LocalizedString(setting.title) uppercaseString];
        if (setting.icon) {
            headerView.iconView.image = [UIImage imageNamed:setting.icon];    
        }
        reusableview = headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        HomeSectionFooterReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        [footerView setSection:indexPath.section];
        [footerView setDelegate:self];
        
        reusableview = footerView;
        
        FooterState state = [self p_settingWithStyle:indexPath.section].state;
        switch (state) {
            case FooterState_Narrow: {
                [footerView updateState:HomeSectionFooterState_Narrow];
            }
                break;
            case FooterState_Extend: {
                [footerView updateState:HomeSectionFooterState_Extend];
            }
                break;
            case FooterState_Loading: {
                [footerView updateState:HomeSectionFooterState_Loading];
            }
                break;
            default:
                break;
        }
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    SectionSetting *setting = [sectionSettingList itemAtIndex:section];
    if (setting.sectionStyle == SectionStyleStatus) {
        return CGSizeZero;
    }
    return CGSizeMake(collectionView.bounds.size.width, 60.);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    SectionSetting *setting = [sectionSettingList itemAtIndex:section];
    if (setting.sectionStyle == SectionStyleStatus) {
        return CGSizeZero;
    }
    return CGSizeMake(collectionView.bounds.size.width, 60);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    SectionSetting *setting = [sectionSettingList itemAtIndex:indexPath.section];
    
    if (setting.sectionStyle == SectionStyleStatus) {
        if (!_lastestPost) {
            CGSizeMake(CGRectGetWidth(collectionView.frame), 50.0);
        }
        
        CGRect rect = [AppUtils boundingRectForString:_lastestPost.content font:[UIFont fontWithName:APPLICATION_FONT size:16] width:CGRectGetWidth(collectionView.frame) - 20.0f];
        
        
        return CGSizeMake(CGRectGetWidth(collectionView.frame), CGRectGetHeight(rect) + 20.0 + 50.0);
    }
    
    int numberOfColumns = MAX(1, setting.numberOfColumns);
    
    if (setting.state == FooterState_Extend) {
        numberOfColumns = setting.numberOfColumnsExtend;
    }
    
    CGFloat width = (_collectionView.bounds.size.width - (numberOfColumns + 1) * 10) / numberOfColumns;
    float height = width + 45.0f;
    
    if (setting.sectionStyle == SectionStyleVideo) {
        height = width/2.0 + 45.0f;
    }
    return CGSizeMake(width - 1, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    SectionSetting *sectionSetting = [sectionSettingList itemAtIndex:section];
    if (sectionSetting.sectionStyle == SectionStyleStatus) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
        return UIEdgeInsetsMake(0, 10, 0, 10);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - HomeSectionFotterReusableViewDelegate
- (void)footerView:(HomeSectionFooterReusableView *)view section:(NSInteger)section performAction:(HomeSectionFooterAction)action {
    SectionSetting *sectionSetting = [sectionSettingList itemAtIndex:section];
    FooterState state = sectionSetting.state;
    
    if (state == FooterState_Extend) {
        state = FooterState_Narrow;
    } else {
        state = FooterState_Extend;
    }
    
    [self p_updateSectionStyle:sectionSetting.sectionStyle withState:state];
    
    [_collectionView performBatchUpdates:^{
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
    } completion:^(BOOL finished) {
        if (state == FooterState_Extend) {
            [view updateState:HomeSectionFooterState_Extend];
        } else {
            [view updateState:HomeSectionFooterState_Narrow];
        }
    }];
}

#pragma mark - 
- (void)sectionBaseView:(SectionReusableBaseView *)view didSelectedDetailSection:(NSInteger)section {
    SectionSetting *sectionSetting = [sectionSettingList itemAtIndex:section];
    
    MusicViewController* vc = [UIStoryboard viewController:SB_MusicViewController storyBoard:StoryBoardMain];
    SectionStyle style = sectionSetting.sectionStyle;
    switch (style) {
        case SectionStyleSong:
            vc.viewType = MusicViewTypeSong;
            break;
        case SectionStyleAlbum:
            vc.viewType = MusicViewTypeAlbum;
            break;
        case SectionStyleVideo:
            vc.viewType = MusicViewTypeVideo;
            break;
        default:
            break;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MediaBaseCellDelagate
- (void)didSelectedCell:(MediaBaseCell *)cell {
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    
    SectionSetting *sectionSetting = [sectionSettingList itemAtIndex:indexPath.section];
    
    NSInteger itemIndex = indexPath.item;
    
    BaseList *list = [_sectionItemDictionary objectWithStyle:sectionSetting.sectionStyle];
    
    id<MediaItem> item = [list itemAtIndex:itemIndex];
    
    switch (sectionSetting.sectionStyle) {
        case SectionStyleVideo: {
            VideoDetailCollectionViewController *vc = (VideoDetailCollectionViewController *)[UIStoryboard viewController:SB_VideoDetailCollectionViewController storyBoard:StoryBoardMain];
            
            if ([list indexOfObject:item] > 0) {
                vc.selectedIndex = [list indexOfObject:item];
            }
            
            [vc setList:(VideoList *)list];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case SectionStyleAlbum: {
            AlbumDetailViewController *albumDetailViewController = [UIStoryboard viewController:SB_AlbumDetailViewController storyBoard:StoryBoardMain];
            albumDetailViewController.albumId = [(Album *)item identifier];
            [self.navigationController pushViewController:albumDetailViewController animated:YES];
        }
            break;
        case SectionStyleSong: {
            NSMutableArray *audioItems = [NSMutableArray array];
            for (Song *aSong in list.items) {
                [audioItems addObject:[AudioItem initBySongObject:aSong]];
            }
            
            [[AudioPlayer shared] play: audioItems startIndex:[list.items indexOfObject:item]];
        }
            break;
        default:
            break;
    }
}
/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float alpha = 0;
    float offset = scrollView.contentOffset.y;
    if (offset > 0) {
        alpha = 0.0;
    } else {
        alpha = MAX(0, fabs(offset/SCREEN_HEIGHT_PORTRAIT));
    }
    _collectionView.alpha = MIN(1 - alpha + 0.1, 1);
    [_homeStatusView updateAlpha:alpha];
}
*/

#pragma mark -
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
