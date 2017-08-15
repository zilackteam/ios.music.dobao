//
//  AppMainViewController.m

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "AppMainViewController.h"
#import "AppUtils.h"
#import "FullPlayerViewController.h"
#import "MiniPlayerView.h"
#import "BaseViewController.h"

@interface AppMainViewController()<MainViewDataSource>

@end

@implementation AppMainViewController
- (id)homeController {
    return [UIStoryboard viewController:SB_HomeCollectionViewController storyBoard:StoryBoardMain];
}

- (UINavigationController *)menuController {
    return [UIStoryboard viewController:SB_NavigationMenuCollectionViewController storyBoard:StoryBoardDirection];
}

- (UIViewController *)playerViewController {
    id vc = [UIStoryboard viewController:SB_CassetterPlayerViewController storyBoard:StoryBoardPlayer];
    return [[UINavigationController alloc] initWithRootViewController:vc];
}

@end
