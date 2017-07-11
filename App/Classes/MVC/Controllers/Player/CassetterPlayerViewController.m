//
//  CassetterPlayerViewController.m
//  music.dobao
//
//  Created by vu tat thanh on 7/11/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "CassetterPlayerViewController.h"
#import "UIViewController+Common.h"
#import "CassetterPlayerView.h"

@interface CassetterPlayerViewController ()<CassetterPlayerViewDelegate> {
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet CassetterPlayerView *cassetter;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

- (void)p_updatePlayerInfo;

@end

@implementation CassetterPlayerViewController
- (void)dealloc {
    [_timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods
- (NSString *)p_formatStringWithSeconds:(int)seconds {
    int s = seconds % 60;
    int m = seconds / 60;
    return [NSString stringWithFormat:@"%02d.%02d", m, s];
}

- (void)p_updatePlayerInfo {
    AudioPlayer *player = [AudioPlayer shared];
    if (player.currentItem) {
        [_cassetter updatePlayInfomation:[[AudioPlayer shared].currentItem name] detail:[[AudioPlayer shared].currentItem detail] duration:player.duration track:(player.playingIndex + 1) totalList:[player.allItems count]];
        
        _durationLabel.text = [self p_formatStringWithSeconds:player.duration];
    }
}

- (void)p_setupTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(p_timerTick) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)p_timerTick {
    AudioPlayer *player = [AudioPlayer shared];
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateActive) {
        if (player.currentItem) {
            [self p_updateProgressingTime:player.progress maxValue:player.duration minValue:0];
        } else {
            [self p_updateProgressingTime:0 maxValue:0 minValue:0];
        }
    }
}

// progress
- (void)p_updateProgressingTime:(float)value maxValue:(float)maxValue minValue:(float)minValue {
    if (maxValue > 0) {
        [_progressView setProgress:(value / maxValue)];
    } else {
        [_progressView setProgress:0];
    }
    _progressLabel.text = [self p_formatStringWithSeconds:(int)value];
    _durationLabel.text = [self p_formatStringWithSeconds:(int)maxValue];
    
    [_cassetter updateProgressingTime:value maxValue:maxValue minValue:minValue];
}

- (void)p_showPlayingList {
    // show playing list
}

#pragma mark - UIView
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"NOW PLAYING";
    [self setLeftNavButton:Back];
    
    [self showRightButtonWithImage:[UIImage imageNamed:@"ic_playing_list"] target:self selector:@selector(p_showPlayingList)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidStartPlayingItem:) name:kNotification_AudioPlayerDidStartPlayingItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateChanged:) name:kNotification_AudioPlayerStateChanged object:nil];
    
    [_cassetter setDelegate:self];
    [self p_updatePlayerInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self p_setupTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_timer) {
        [_timer invalidate];
    }
}

- (void)backButtonSelected {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - CassetterPlayerView Delegate

- (void)playerView:(CassetterPlayerView *)view performAction:(CassetterPlayAction) action optionValue:(float)value {
    AudioPlayer *player = [AudioPlayer shared];
    switch (action) {
        case CassetterPlayActionPlay: {
            
            if (player.state == STKAudioPlayerStatePlaying || player.state == STKAudioPlayerStateBuffering) {
            } else {
                [player resume];
            }
        }
            break;
        case CassetterPlayActionPause: {
            if (player.state == STKAudioPlayerStatePlaying || player.state == STKAudioPlayerStateBuffering) {
                [player pause];
            }
        }
            break;
        case CassetterPlayActionNext: {
            [[AudioPlayer shared] next];
        }
            break;
        case CassetterPlayActionPrevious: {
            [[AudioPlayer shared] previous];
        }
            break;
        case CassetterPlayActionRepeat: {
            NSInteger type = player.loopType + 1;
            type = type > AudioPlayerLoopTypeAll ? AudioPlayerLoopTypeNone : type;
            [player setLoopType:(AudioPlayerLoopType)type];
            
//            [[self playingCell] updateLoopState:(AudioPlayerLoopType)type];
        }
            break;
        case CassetterPlayActionShuffle: {
            BOOL shuffle = ![player shuffle];
            [player setShuffle:shuffle];
//            [[self playingCell] updateShuffle:shuffle];
        }
            break;
            
        case CassetterPlayActionVolumnChanged: {
            player.volume = value;
        }
            break;
        case CassetterPlayActionProgressChanged: {
            [player seekToOffset:value];
        }
            break;
        default:
            break;
    }
}

#pragma mark - AudioPlayerListener
- (void)playerDidStartPlayingItem:(NSNotification *)notification {
    [self p_updatePlayerInfo];
}

- (void)playerStateChanged:(NSNotification *)notification {
    [self p_updatePlayerInfo];
}
@end
