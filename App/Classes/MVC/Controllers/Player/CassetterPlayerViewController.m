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

@interface CassetterPlayerViewController ()<CassetterPlayerViewDelegate>
@property (weak, nonatomic) IBOutlet CassetterPlayerView *cassetter;

@end

@implementation CassetterPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"NOW PLAYING";
    [self setLeftNavButton:Back];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidStartPlayingItem:) name:kNotification_AudioPlayerDidStartPlayingItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateChanged:) name:kNotification_AudioPlayerStateChanged object:nil];
    
    AudioPlayer *player = [AudioPlayer shared];
    if (player.currentItem) {
        [_cassetter updatePlayInfomation:[[AudioPlayer shared].currentItem name] detail:[[AudioPlayer shared].currentItem detail] duration:player.duration track:player.playingIndex totalList:[player.allItems count]];
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
    
}

#pragma mark - AudioPlayerListener
- (void)playerDidStartPlayingItem:(NSNotification *)notification {
    AudioPlayer *player = [AudioPlayer shared];
    [_cassetter updatePlayInfomation:[[AudioPlayer shared].currentItem name] detail:[[AudioPlayer shared].currentItem detail] duration:player.duration track:player.playingIndex totalList:[player.allItems count]];
}

- (void)playerStateChanged:(NSNotification *)notification{
}
@end
