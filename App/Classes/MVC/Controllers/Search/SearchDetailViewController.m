//
//  SearchDetailViewController.m

//
//  Created by thanhvu on 1/17/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "VideoDetailCollectionViewController.h"
#import "MusicViewController.h"
#import "AlbumDetailViewController.h"
#import "ApiDataObjects.h"

@interface SearchDetailViewController()<AppSearchResultDelegate> {
}
@end

@implementation SearchDetailViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark -
- (void)appSearchResult:(AppSearchResultViewController *)viewController didSelectedSection:(SeachSectionStyle)style resultList:(BaseList *)list index:(NSInteger)index {
    switch (style) {
        case SearchSectionStyleSong: {
        }
            break;
        case SearchSectionStyleAlbum: {
            Album *album = [list itemAtIndex:index];
            AlbumDetailViewController *vc = [UIStoryboard viewController:SB_AlbumDetailViewController storyBoard:StoryBoardMain];
            vc.albumId = album.identifier;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case SearchSectionStyleVideo: {
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
