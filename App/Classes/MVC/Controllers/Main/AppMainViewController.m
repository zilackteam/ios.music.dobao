//
//  AppMainViewController.m

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "AppMainViewController.h"
#import "AppUtils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FullPlayerViewController.h"
#import "MiniPlayerView.h"
#import "BaseViewController.h"

@interface AppMainViewController()<AudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet MiniPlayerView *miniPlayer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMiniPlayerConstraint;

@end

@implementation AppMainViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:
                                                        [UIStoryboard viewController:SB_HomeCollectionViewController storyBoard:StoryBoardMain]];
/*
    [homeNavigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [homeNavigationController.navigationBar setShadowImage:[UIImage new]];
    [homeNavigationController.navigationBar setTranslucent:YES];
*/
    self.contentViewController      = homeNavigationController;
    self.menuViewController         = [UIStoryboard viewController:SB_NavigationMenuCollectionViewController storyBoard:StoryBoardDirection];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [AudioPlayer shared].delegate = self;
    [self.view bringSubviewToFront:_miniPlayer];
    if ([AudioPlayer shared].allItems.count != 0) {
        _miniPlayer.alpha = 1.0;
        _bottomMiniPlayerConstraint.constant = 0;
    }
    
    _miniPlayer.userInteractionEnabled = YES;
    [_miniPlayer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOnMiniPlayer:)]];
}

#pragma mark - Private methods
- (void)showFullPlayer{
    if ([AudioPlayer shared].currentItem) {
        FullPlayerViewController *vc = [UIStoryboard viewController:SB_FullPlayerViewController storyBoard:StoryBoardPlayer];
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
}
#pragma mark - AudioPlayerDelegate
- (void) startPlayer:(AudioPlayer *)player {
    if (_bottomMiniPlayerConstraint.constant != 0 && [AudioPlayer shared].allItems.count != 0) {
        [UIView animateWithDuration:0.5 animations:^{
            _miniPlayer.alpha = 1.0;
            _bottomMiniPlayerConstraint.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            UIViewController *currentVisibleVc = self.contentViewController;
            if ([currentVisibleVc isKindOfClass:[UINavigationController class]]) {
                currentVisibleVc = [(UINavigationController *)currentVisibleVc topViewController];
            }
            if ([currentVisibleVc isKindOfClass:[BaseViewController class]]) {
                [(BaseViewController *)currentVisibleVc updateBottomLayout];
            }
        }];
    }
}

- (void) stopPlayer:(AudioPlayer *)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            _miniPlayer.alpha = 0.0;
            _bottomMiniPlayerConstraint.constant = -APPLICATION_MINI_PLAYER_HEIGHT;
            [self.view layoutIfNeeded];
        }];
    });
    
    UIViewController *currentVisibleVc = self.contentViewController;
    if ([currentVisibleVc isKindOfClass:[UINavigationController class]]) {
        currentVisibleVc = [(UINavigationController *)currentVisibleVc topViewController];
    }
    if ([currentVisibleVc isKindOfClass:[BaseViewController class]]) {
        [(BaseViewController *)currentVisibleVc updateBottomLayout];
    }
}

- (void)onTapOnMiniPlayer:(UITapGestureRecognizer *)gesture {
    [self showFullPlayer];    
}


@end
