//
//  LiveBroadCastingViewController.m
//  music.application
//
//  Created by thanhvu on 5/29/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "LiveBroadCastingViewController.h"
#import "UIViewController+Common.h"
#import "LFLivePreview.h"
#import "LiveBottomView.h"
#import "LiveTopView.h"
#import "ZLRoundButton.h"
#import "BroadCastBottomView.h"
#import "APIClient.h"

#include "AppDelegate.h"

@interface LiveBroadCastingViewController ()<LFLivePreviewDelegate, LiveBottomViewDelegate, LiveTopViewDelegate, BroadCastBottomViewDelegate> {
    LFLivePreview* preview;
}

@property (nonatomic, strong) UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet LiveTopView *topView;
@property (weak, nonatomic) IBOutlet BroadCastBottomView *broadCastBottomView;

@property (strong, nonatomic) LiveConfiguration *liveConfiguration;
@property (nonatomic, assign) LiveStreamViewState viewState;

- (void)p_updateStatusOnline:(BOOL)online;
- (void)p_createLiveStreaming;
- (void)p_startStream;

@end

@implementation LiveBroadCastingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AppDelegate sharedInstance] musicStop];
    
    preview = [[LFLivePreview alloc] initWithFrame:self.view.bounds];
    preview.delegate = self;
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:preview];
    
    self.viewState = LiveStreamViewStateNone; // default state
    {
        [_broadCastBottomView updateTitle:LocalizedString(@"tlt_live_publish")];
        
        [_stateLabel.layer setCornerRadius:15.0];
        [_stateLabel.layer setBorderColor:RGBA(255.0, 255.0, 255.0, 0.2).CGColor];
        [_stateLabel.layer setBorderWidth:1.0];
        
        [_stateLabel setClipsToBounds:YES];
        [_stateLabel setBackgroundColor:RGBA(255, 255, 255, 0.1)];
        
        [self p_updateStatusOnline:NO];
        
        [_topView.layer setBorderColor:RGBA(255.0, 255.0, 255.0, 0.2).CGColor];
        [_topView setDelegate:self];
    }
    
    [self.view addSubview:self.closeButton];
    
    _broadCastBottomView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)p_updateStatusOnline:(BOOL)online {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_broadCastBottomView updateStreamState:online?StreamStateLive:StreamStateOffline];
        if (online) {
            _viewState = LiveStreamViewStateLiveConnected;
            [_stateLabel setBackgroundColor:RGBA(255, 1, 1, 1)];
            [_stateLabel setText:LocalizedString(@"msg_live_state_live")];
            
            [[APIClient shared] activeLiveId:_liveConfiguration.identifier
                                       title:_broadCastBottomView.liveTitle
                                  completion:^(BOOL success, LiveConfiguration * configuration) {
            }];
        } else {
            _viewState = LiveStreamViewStateLiveDisconnect;
            [_stateLabel setBackgroundColor:RGBA(255, 255, 255, 0.1)];
            [_stateLabel setText:LocalizedString(@"msg_live_state_off")];
            
            if (_liveConfiguration) {
                [[APIClient shared] finishLiveId:_liveConfiguration.identifier completion:^(BOOL success) {
                    if (success) {
                    }
                }];
            }
        }
    });
}

- (void)tapOnBackground:(UITapGestureRecognizer *)gesture {
    [self hideKeyboard];
    
    if (!_liveConfiguration || _viewState == LiveStreamViewStateConfigLoading) {
        return;
    }
    
    ViewState state = ViewStateInit;
    switch (_viewState) {
        case LiveStreamViewStateNone:
            break;
        case LiveStreamViewStateConfigLoading:
            state = ViewStateLive;
            break;
        case LiveStreamViewStateConfigSuccess:
            state = ViewStateLive;
            break;
        case LiveStreamViewStateConfigFailure:
            break;
        case LiveStreamViewStateLiveConnected:
            state = ViewStateLive;
            break;
        case LiveStreamViewStateLiveConnecting:
            state = ViewStateLive;
            break;
        case LiveStreamViewStateLiveDisconnect:
            state = ViewStateInit;
            break;
        default:
            break;
    }
    
    [_broadCastBottomView updateState:state option:0 complete:^(BOOL success) {
    }];
}

- (void)p_createLiveStreaming {
    NSString *liveTitle = _broadCastBottomView.liveTitle;
    if (liveTitle) {
        if (!_liveConfiguration && _viewState != LiveStreamViewStateConfigLoading) {
            _viewState = LiveStreamViewStateConfigLoading;
            
            [_broadCastBottomView updateStreamState:StreamStateWaiting];
            
            // Get configuration of streaming server
            [[APIClient shared] requestLiveBroadcastCast:[[Session shared] appId] completion:^(BOOL success, LiveConfiguration *configuration) {
                if (success && configuration) {
                    _liveConfiguration = configuration;
                    _viewState = LiveStreamViewStateConfigSuccess;
                    // setup chat with MQTT
                    [self setupChatMQTTAddress:configuration.address];
                    // start stream
                    [self p_startStream];
                } else {
                    _viewState = LiveStreamViewStateConfigFailure;
                }
            }];
        }
    } else {
        [_broadCastBottomView updateState:ViewStateInit option:0 complete:^(BOOL success) {
        }];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:LocalizedString(@"msg_error_require_live_title")
                                                           delegate:nil
                                                  cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)p_startStream {
    if (_liveConfiguration) {
        _viewState = LiveStreamViewStateLiveConnecting;
        [preview flipLiveStreaming:_liveConfiguration.streamUrl openSteam:^(BOOL open) {
            if (!open) {
            }
        }];
    } else {
        [self p_createLiveStreaming];
    }
}

#pragma mark - buttons control

- (UIButton *)closeButton {
    if ( !_closeButton ) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(15, 20, 44, 44);
        [_closeButton setImage:[UIImage imageNamed:@"ic_menu_live"] forState:UIControlStateNormal];
    }
    
    [_closeButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_onClose)]];
    return _closeButton;
}

- (void)p_onClose {
    [self p_updateStatusOnline:NO];
    [preview closeStream];

    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)p_onChangeCamera {
    [preview flipCamera];
}

#pragma mark - LFLivePreview Delegate
- (void)livePreview:(LFLivePreview *)view changeState:(LFLivePreviewState)state {
    NSString *tlt = LocalizedString(@"tlt_live_publish");
    switch (state) {
        case LFLivePreviewStateReady: {
            tlt = LocalizedString(@"tlt_live_publish");
            [self p_updateStatusOnline:NO];
        }
            break;
        case LFLivePreviewStatePending: {
            tlt = LocalizedString(@"tlt_live_finish");
            [self p_updateStatusOnline:NO];
        }
            break;
        case LFLivePreviewStateStart: {
            tlt = LocalizedString(@"tlt_live_finish");
            [self p_updateStatusOnline:YES];
        }
            break;
        case LFLivePreviewStateStop: {
            tlt = LocalizedString(@"tlt_live_publish");
            [self p_updateStatusOnline:NO];
        }
            break;
        case LFLivePreviewStateError: {
            tlt = LocalizedString(@"tlt_live_error");
            [self p_updateStatusOnline:NO];
        }
            break;
        case LFLivePreviewStateRefresh: {
            tlt = @"...";
            [self p_updateStatusOnline:NO];
        }
            break;
        default:
            break;
    }
    
    [_broadCastBottomView updateTitle:tlt];
}

#pragma mark - LiveTopView Delegate
- (void)liveTopView:(LiveTopView *)view performAction:(LiveTopViewAction)action {
    switch (action) {
        case LiveTopViewActionChangeCamera:
            [preview flipCamera];
            break;
        case LiveTopViewActionChangeBeautyFilter:
            [_topView useBeautyFilter:[preview flipBeauty]];
            break;
        default:
            break;
    }
}

#pragma mark - BoardCastBottomView Delegate
- (void)broadCastBottomView:(BroadCastBottomView *)view selectedChatButton:(UIButton *)button {
    if (_viewState == LiveStreamViewStateLiveConnected) {
        [view updateState:ViewStateChat option:0 complete:^(BOOL success) {
        }];
    }
}

- (void)broadCastBottomView:(BroadCastBottomView *)view changeState:(ViewState)state {
    self.controlHeightConstraint.constant = [view heightOfState];
    switch (state) {
        case ViewStateNone: {
            self.contentBottomConstraint.constant = 0.0f;
        }
            break;
        case ViewStateChat: {
        }
            break;
        case ViewStateGift: {
            self.contentBottomConstraint.constant = [view heightOfState];
        }
            break;
        case ViewStateInit: {
        }
            break;
        default:
            break;
    }
    
    [UIView animateKeyframesWithDuration:0.4
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionAllowUserInteraction
                              animations:^{
                                  [self.view layoutIfNeeded];
                              } completion:^(BOOL finished) {
                              }];
}

- (void)broadCastBottomView:(BroadCastBottomView *)view liveWithTitle:(NSString *)title {
    [self p_startStream];
}

- (void)disconnectLiveStreaming {
    [self p_updateStatusOnline:NO];
    [preview closeStream];
}

- (void)broadCastBottomView:(BroadCastBottomView *)view sendTextMessage:(NSString *)message {
    [self sendTextMessage:message];
}

- (void)broadCastBottomView:(BroadCastBottomView *)view sendGiftMessage:(NSString *)message {
    
}

- (void)broadCastBottomView:(BroadCastBottomView *)view soundActive:(BOOL)active {
    [preview setMute:!active];
}
@end
