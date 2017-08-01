//
//  HomeCollectionViewController.m
//  music.application
//
//  Created by thanhvu on 3/18/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeCollectionViewController.h"
#import "AppHomeStatusView.h"
#import "MusicViewController.h"
#import "VideoDetailCollectionViewController.h"
#import "AlbumDetailViewController.h"
#import "CommentViewController.h"

#import "HomeSectionHeaderReusableView.h"
#import "HomeSectionFooterReusableView.h"

#import "Album.h"
#import "AppDelegate.h"

#import "HomeCollectionManager.h"

#pragma mark - HomeCollectionViewController Implement
@interface HomeCollectionViewController ()<AppHomeProtocol, AppHomeStatusDelegate> {
}

@end

@implementation HomeCollectionViewController

#pragma mark - AppHomeProtocol
- (int)initLimitSong {
    return 9;
}

- (int)initLimitVideo {
    return 6;
}

- (int)initLimitAlbum {
    return 9;
}

- (NSInteger)homeContentCachedRefreshTimeInMinutes {
    return 60 * 6;
}

- (NSString *)homeSectionCellIdentifierWithStyle:(SectionStyle) style {
    switch (style) {
        case SectionStyleVideo:
            return @"video_cell";
            break;
        case SectionStyleSong:
            return @"song_collection_cell";
            break;
        case SectionStyleAlbum:
            return @"item_cell";
            break;
        case SectionStyleStatus:
            return @"status_cell";
            break;
        default:
            return nil;
    }
}

- (void)homeCollectionView:(UICollectionView *)collectionView {
    collectionView.scrollEnabled = NO;
    collectionView.backgroundView.backgroundColor = RGB(1, 1, 1);
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, APPLICATION_MINI_PLAYER_HEIGHT, 0);
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 10;
    currentLayout.minimumInteritemSpacing = 10;
    [currentLayout invalidateLayout];
}

- (void)homeCollectionView:(UICollectionView *)collectionView registerHomeHeaderSectionClass:(__unsafe_unretained Class *)headerClass headerSectionFooterClass:(__unsafe_unretained Class *)footerClass {
    *headerClass = [HomeSectionHeaderReusableView class];
    *footerClass = [HomeSectionFooterReusableView class];
}

- (void)appHomeCollection:(AppHomeCollectionViewController *)viewController didSelectedSection:(SectionStyle)style resultList:(BaseList *)list index:(NSInteger)index {
    id<MediaItem> item = [list itemAtIndex:index];
    
    switch (style) {
        case SectionStyleVideo: {
            VideoDetailCollectionViewController *vc = (VideoDetailCollectionViewController *)[UIStoryboard viewController:SB_VideoDetailCollectionViewController storyBoard:StoryBoardMain];
            [vc setList:(VideoList *)list];
            vc.selectedIndex = index;
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
        }
            break;
        default:
            break;
    }
}

- (CGSize)appHomeCollection:(AppHomeCollectionViewController *)viewController sizeForItemOfSectionSetting:(SectionSetting *)setting {
    if (setting.sectionStyle == SectionStyleStatus) {
        if (![self getLastestPost]) {
            CGSizeMake(CGRectGetWidth(self.collectionView.frame), 50.0);
        }
        
        CGRect rect = [AppUtils boundingRectForString:[self getLastestPost].content font:[UIFont fontWithName:APPLICATION_FONT size:16] width:CGRectGetWidth(self.collectionView.frame) - 20.0f];
        return CGSizeMake(CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(rect) + 20.0 + 50.0);
    }

    int numberOfColumns = MAX(1, setting.numberOfColumns);
    
    if (setting.state == FooterState_Extend) {
        numberOfColumns = setting.numberOfColumnsExtend;
    }
    
    if (setting.sectionStyle == SectionStyleSong) {
        return CGSizeMake(CGRectGetWidth(self.collectionView.bounds) - (numberOfColumns + 1) * 10, 80.0f);
    }
    
    CGFloat width = (CGRectGetWidth(self.collectionView.bounds) - (numberOfColumns + 1) * 10) / numberOfColumns;
    float height = width + 45.0f;
    
    if (setting.sectionStyle == SectionStyleVideo) {
        height = width/2.0 + 45.0f;
    }
    return CGSizeMake(width - 1, height);
}

#pragma mark - AppHomeStatusDelegate
- (void)homeStatusView:(AppHomeStatusView *)homeStatusView performAction:(HomeStatusAction)action {
    if (action == HomeStatusActionScrollDown) {
        [self.collectionView setContentOffset:CGPointMake(0, CGRectGetHeight(self.view.frame)) animated:YES];
    } else {
        if ([self getLastestPost]) {
            CommentViewController *vc = (CommentViewController *)[UIStoryboard viewController:SB_CommentViewControler storyBoard:StoryBoardSocial];
            vc.post = [self getLastestPost];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - View Load
- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self useMainBackgroundOpacity:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)updateLocalization {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
- (void)sectionBaseView:(SectionReusableBaseView *)view didSelectedDetailSection:(NSInteger)section {
    SectionSettingList *settingList = [self getSectionSettingList];
    SectionSetting *sectionSetting = [settingList itemAtIndex:section];
    
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

@end
