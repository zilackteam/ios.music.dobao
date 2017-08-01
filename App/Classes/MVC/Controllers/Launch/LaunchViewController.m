//
//  LaunchViewController.m
//  music.application
//
//  Created by thanhvu on 4/13/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "LaunchViewController.h"
#import "HomeStatusView.h"
#import "AppDelegate.h"

@interface LaunchViewController ()<AppLauchProtocol>
{
    HomeStatusView *_statusView;
}

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// overrive search method from base
- (void)searchButtonSelected {
}

// overrive show menu from base
- (void)menuButtonSelected {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - AppLauchProtocol
- (void)appVerifyState:(AppVerifyState)aState {
    switch (aState) {
        case AppVerifyStateSuccess: {
            [[AppDelegate sharedInstance] registerDeviceToken];
        }
            break;
        case AppVerifyStateUpdate: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_statusView updateMessage:LocalizedString(@"msg_update_appversion_require")];
            });
        }
            break;
        case AppVerifyStateFailure: {
        }
            break;
        default:
            break;
    }
}

- (UIViewController *)appMainViewController {
    return [UIStoryboard viewController:SB_AppMainViewController storyBoard:StoryBoardMain];
}

- (void)statusView:(AppHomeStatusView *)statusView {
    _statusView = (HomeStatusView *)statusView;
}

@end
