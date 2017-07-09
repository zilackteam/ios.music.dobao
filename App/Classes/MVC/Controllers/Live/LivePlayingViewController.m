//
//  LivePlayingViewController.m
//  music.application
//
//  Created by thanhvu on 5/29/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "LivePlayingViewController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "AppDelegate.h"
#import "LiveStatusView.h"
#import "LiveBottomView.h"
#import "APIClient.h"

@interface LivePlayingViewController ()<LiveBottomViewDelegate>

@property (nonatomic, strong) UIButton *closeButton;
@property (atomic, retain) id<IJKMediaPlayback> player;
@property (weak, nonatomic) IBOutlet LiveBottomView *bottomView;

@property (strong, nonatomic) LiveStatusView *statusView;

@property (strong, nonatomic) LiveConfiguration *liveConfiguration;

@property (nonatomic, assign) LiveStreamViewState viewState;

- (void)p_getLiveConfiguration;

- (void)p_initPlayer;

@end

@implementation LivePlayingViewController

#define EXPECTED_IJKPLAYER_VERSION (1 << 16) & 0xFF) |
- (void)viewDidLoad {
    [super viewDidLoad];
    [[AppDelegate sharedInstance] musicStop];
    
    _viewState = LiveStreamViewStateNone; // default state
    
    [self.view addSubview:self.statusView];
    [self.view insertSubview:self.closeButton aboveSubview:self.statusView];
    [self.view bringSubviewToFront:self.bottomView];
    [self.bottomView setDelegate:self];
    
    // default
    [_statusView updateLiveStatusViewState:LiveStatusViewStateOffline];
}

- (void)p_initPlayer {
    dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:YES];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
        
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        
//        [options setCodecOptionIntValue:IJK_AVDISCARD_ALL forKey:@"skip_loop_filter"]; //IJK_AVDISCARD_ALL
//        [options setCodecOptionIntValue:IJK_AVDISCARD_NONREF forKey:@"skip_frame"]; //IJK_AVDISCARD_NONREF
        
        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_liveConfiguration.streamUrl] withOptions:options];
        self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.player.view.frame = self.view.bounds;
        self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
        self.player.shouldAutoplay = YES;
        
        self.view.autoresizesSubviews = YES;
        [self.view insertSubview:self.player.view belowSubview:self.contentView];
        
        [self.player prepareToPlay];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)p_getLiveConfiguration {
    if (_viewState >= LiveStreamViewStateConfigLoading) {
        return;
    }
    
    _viewState = LiveStreamViewStateConfigLoading;
    [[APIClient shared] getLiveStreamAppId:[[Session shared] appId] completion:^(BOOL success, LiveConfiguration *liveConfiguration) {
        _liveConfiguration = liveConfiguration;
        if (success && liveConfiguration) {
            [self p_initPlayer];
            
            [self setupChatMQTTAddress:liveConfiguration.address];
            
            _viewState = LiveStreamViewStateConfigSuccess;
            
            if (liveConfiguration.title) {
                [_statusView setTitle:liveConfiguration.title];
            }
            [_bottomView updateState:ViewStateNone option:0 complete:^(BOOL success) {
            }];
        } else {
            _viewState = LiveStreamViewStateConfigFailure;
        }
    }];
}

- (void)tapOnBackground:(UITapGestureRecognizer *)gesture {
    [self hideKeyboard];
    
    CGPoint locationPoint = [gesture locationInView:self.view];
    
    if ( CGRectContainsPoint(_bottomView.frame, locationPoint) ) {
        // Point lies inside the bounds.
        return;
    }
    
    switch (_viewState) {
        case LiveStreamViewStateNone:
        case LiveStreamViewStateConfigLoading:
        case LiveStreamViewStateConfigSuccess:
        case LiveStreamViewStateConfigFailure:
        case LiveStreamViewStateLiveConnected:
        case LiveStreamViewStateLiveConnecting:
        case LiveStreamViewStateLiveDisconnect:
            break;
            
        default:
            break;
    }
    [_bottomView updateState:ViewStateNone option:0 complete:^(BOOL success) {
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self installMovieNotificationObservers];
    
    [self p_getLiveConfiguration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(15, 20, 44, 44);
        [_closeButton setImage:[UIImage imageNamed:@"ic_menu_live"] forState:UIControlStateNormal];
    }
    
    [_closeButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClose)]];
    return _closeButton;
}

- (UIView *)bottomView {
    _bottomView.backgroundColor = [UIColor clearColor];
    return _bottomView;
}

- (LiveStatusView *)statusView {
    UIView *view = self.view;
    if (!_statusView) {
        _statusView = [LiveStatusView nib];
        _statusView.frame = CGRectMake(0, 20, CGRectGetWidth(view.frame), CGRectGetHeight(_statusView.frame));
    }
    return _statusView;
}

- (void)onClose {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadStateDidChange:(NSNotification*)notification {
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification {
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    _viewState = LiveStreamViewStateLiveDisconnect;
    
    [_statusView updateLiveStatusViewState:LiveStatusViewStateOffline];
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            [_statusView updateLiveStatusViewState:LiveStatusViewStateOnline];
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark - LiveBottomViewDelegate
- (void)liveBottomView:(LiveBottomView *)view changeState:(ViewState)state {
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
    
    [UIView animateWithDuration:0.4 animations:^{
       [self.view layoutIfNeeded];
    }];
}

- (void)liveBottomView:(LiveBottomView *)view sendTextMessage:(NSString *)message {
    [self sendTextMessage:message];
}

- (void)liveBottomView:(LiveBottomView *)view sendGiftMessage:(NSString *)message {
    [self sendGiftMessage:message];
}

@end
