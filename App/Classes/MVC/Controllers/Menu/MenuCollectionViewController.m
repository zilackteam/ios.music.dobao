//
//  MenuCollectionViewController.m
//  music.application
//
//  Created by thanhvu on 3/21/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "MenuCollectionViewController.h"
#import "MusicViewController.h"
#import "MyMusicViewController.h"

#pragma mark - MenuCollectionViewController Implementation
@interface MenuCollectionViewController ()<AppMenuCollectionProtocol> {
}

@end

@implementation MenuCollectionViewController

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - AppMenuCollectionProtocol
- (void)menuCollectionView:(UICollectionView *)collectionView avatarView:(UIImageView *)avatarView {
    // collectionView
    collectionView.backgroundColor  = [UIColor whiteColor];
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, APPLICATION_MINI_PLAYER_HEIGHT, 0);
    collectionView.allowsSelection = YES;
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 10;
    currentLayout.minimumInteritemSpacing = 10;
    [currentLayout invalidateLayout];

    // avatar
    avatarView.layer.cornerRadius = avatarView.frame.size.height/2.0;
    avatarView.layer.borderWidth = 1.0f;
    avatarView.layer.borderColor = RGB(255, 255, 255).CGColor;
}

- (NSString *)menuPlistConfigurationFile {
    return @"main_menu";
}

- (BOOL)menuExpandable {
    return NO;
}

- (void)menuSelectedSection:(MenuSection *)section object:(MenuObject *)object {
    if (!object.identifier || [object.identifier isEqualToString:@""]) {
        return;
    }
    
    if ([object.identifier isEqualToString:SB_LiveStreamingViewController])
    {
        id vc = nil;
        if ([[Session shared] signedIn] && [Session shared].user.level == UserLevelMaster)
        {
            vc = [UIStoryboard viewController:SB_LiveBroadCastingViewController storyBoard:object.storyBoard];
        }
        else
        {
            vc = [UIStoryboard viewController:SB_LivePlayingViewController storyBoard:object.storyBoard];
        }
        [self presentViewController:vc animated:YES completion:^{
        }];
    } else {
        UIViewController *vc = [UIStoryboard viewController:object.identifier storyBoard:object.storyBoard];
        
        if (vc == nil) {
            return;
        }
        
        if ([object.identifier isEqualToString:SB_MusicViewController]) {
            NSString *value = object.optionValue;
            if ([value isEqualToString:@"video"]) {
                [(MusicViewController *)vc setViewType:MusicViewTypeVideo];
            } else if ([value isEqualToString:@"song"]) {
                [(MusicViewController *)vc setViewType:MusicViewTypeSong];
            } else if ([value isEqualToString:@"album"]) {
                [(MusicViewController *)vc setViewType:MusicViewTypeAlbum];
            } else if ([value isEqualToString:@"single"]) {
                [(MusicViewController *)vc setViewType:MusicViewTypeSingle];
            }
        } else if ([object.identifier isEqualToString:SB_MyMusicViewController]) {
            NSString *value = object.optionValue;
            if ([value isEqualToString:@"offline"]) {
                [(MyMusicViewController *)vc setMode:MyMusicMode_Offline];
            } else {
                [(MyMusicViewController *)vc setMode:MyMusicMode_Online];
            }
        }
        
        self.frostedViewController.contentViewController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.frostedViewController hideMenuViewController];
    }
}

- (void)didSelectedMenuAccount {
    id viewController = [UIStoryboard viewController:SB_Nav_AccountManagerController storyBoard:StoryBoardAccount];
    
    [self.frostedViewController hideMenuViewController];
    self.frostedViewController.contentViewController = viewController;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    return 90.0f;
}

@end
