//
//  LaunchViewController.m
//  music.application
//
//  Created by thanhvu on 4/13/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "LaunchViewController.h"
#import "AppMainViewController.h"
#import "APIClient.h"
#import "Session.h"
#import "Auth.h"
#import "HomeStatusView.h"
#import "AppUtils.h"
#import "ApiDataProvider.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, LaunchState) {
    LaunchState_None,
    LaunchState_Init,
    LaunchState_Loading,
    LaunchState_AppVersionChecking,
    LaunchState_SugesstionLoading,
    LaunchState_Error,
    LaunchState_Finish
};

@interface LaunchViewController ()
{
    __weak IBOutlet HomeStatusView *statusView;
    
    LaunchState state;
}

- (void)p_appVersionChecking;
- (void)p_appSuggestion;
- (void)p_appLogin;
- (void)p_appLaunchHomeScreen;
- (void)p_updateState: (LaunchState)state;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.title = LocalizedString(@"tlt_home");
    
    [self setLeftNavButton:Menu];
    [self showSearchButton];
    
    [statusView updateAlpha:1];
    
    state = LaunchState_None;
    // init state
    [self p_updateState:LaunchState_Init];
    // auto login
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
    [self p_updateState:LaunchState_AppVersionChecking];
    // configuration
}

#pragma mark - Private Methods
- (void)p_appVersionChecking { // verify application's version
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Auth shared] verifyApplication:^(AppVerifyState appState) {
            switch (appState) {
                case AppVerifyStateSuccess: {
                    [[AppDelegate sharedInstance] registerDeviceToken];
                    [self p_appLogin];
                    [self p_updateState:LaunchState_SugesstionLoading];
                }
                    break;
                case AppVerifyStateUpdate: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [statusView updateMessage:LocalizedString(@"msg_update_appversion_require")];
                        [self p_updateState:LaunchState_Finish];
                    });
                }
                    break;
                case AppVerifyStateFailure: {
                    [self p_updateState:LaunchState_Finish];
                }
                    break;
                default:
                    break;
            }
        }];
    });
}

- (void)p_appSuggestion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ApiDataProvider fetchSuggestions:^(NSArray* suggestions, BOOL completed) {
            [self p_updateState:LaunchState_Finish];
        } refreshTimeInMinutes:24 * 60];
    });
}

- (void)p_appLaunchHomeScreen {
    dispatch_async(dispatch_get_main_queue(), ^{
        AppMainViewController *vc = [UIStoryboard viewController:SB_AppMainViewController storyBoard:StoryBoardMain];
        [UIApplication sharedApplication].delegate.window.rootViewController = vc;
    });
}

- (void)p_appLogin {
    [[Auth shared] loginWithEmailStored];
}

- (void)p_updateState:(LaunchState)aState {
    if (state == aState) {
        return;
    }
    [statusView showLoading];
    
    switch (aState) {
        case LaunchState_Init:
            break;
        case LaunchState_Loading:
            break;
        case LaunchState_SugesstionLoading: {
            [self p_appSuggestion];
        }
            break;
        case LaunchState_AppVersionChecking: {
            [self p_appVersionChecking];
        }
            break;
        case LaunchState_Error: {
            [statusView hideLoading];
        }
            break;
        case LaunchState_Finish: {
            [statusView hideLoading];
            [self p_appLaunchHomeScreen];
        }
            break;
        default:
            break;
    }
}

@end
