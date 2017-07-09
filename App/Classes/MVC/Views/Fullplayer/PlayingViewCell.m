//
//  PlayingViewCell.m
//  music.application
//
//  Created by thanhvu on 3/25/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "PlayingViewCell.h"
#import "ExSlider.h"

@interface PlayingViewCell()

@property (weak, nonatomic) IBOutlet ExSlider *progressSlider;
@property (weak, nonatomic) IBOutlet ExSlider *volumnSlider;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFavouriteButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation PlayingViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_progressSlider setThumbImage:[UIImage imageNamed:@"ic_time_slider_thumb"] forState:UIControlStateNormal];
    [_volumnSlider setThumbImage:[UIImage imageNamed:@"ic_volumn_slider_thumb"] forState:UIControlStateNormal];
}

#pragma mark - Utility
- (NSString *)formatStringWithSeconds:(int)seconds {
    int s = seconds % 60;
    int m = seconds / 60;
    return [NSString stringWithFormat:@"%02d:%02d", m, s];
}

- (BOOL)p_isActionResponsable {
    return _delegate && [_delegate respondsToSelector:@selector(playerView:performAction:optionValue:)];
}

- (BOOL)p_isMediaActionResponsable {
    return _delegate && [_delegate respondsToSelector:@selector(playerView:performMediaAction:)];
}

#pragma mark - Update Status
- (void)updatePlayInfomation:(NSString *)name detail:(NSString *)detail {
    _nameLabel.text = name;
    _detailLabel.text = detail;
}

- (void)updatePlayInfomation:(NSString *)name detail:(NSString *)detail favourite:(BOOL)favourite {
    [self updatePlayInfomation:name detail:detail];
    
    if (favourite) {
        [_addFavouriteButton setImage:[UIImage imageNamed:@"ic_media_add_favourite_hl"] forState:UIControlStateNormal];
    } else {
        [_addFavouriteButton setImage:[UIImage imageNamed:@"ic_media_add_favourite_white"] forState:UIControlStateNormal];
    }
}

// player state
- (void)updatePlayerState:(PlayerState) state {
    if (state == PlayerStatePlaying || state == PlayerStateBuffering) {
        [self.playButton setImage:[UIImage imageNamed:@"ic_media_pause_hl"] forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"ic_media_play_hl"] forState:UIControlStateNormal];
    }
}

// update volumn
- (void)updateVolumn:(float)value {
    _volumnSlider.value = value;
}

// loop
- (void)updateLoopState:(AudioPlayerLoopType)type {
    switch (type) {
        case AudioPlayerLoopTypeAll:{
            [self.repeatButton setImage:[UIImage imageNamed:@"ic_media_repeat_all"] forState:UIControlStateNormal];
        }
            break;
        case AudioPlayerLoopTypeNone:{
            [self.repeatButton setImage:[UIImage imageNamed:@"ic_media_repeat_none"] forState:UIControlStateNormal];
        }
            break;
        case AudioPlayerLoopTypeOne:{
            [self.repeatButton setImage:[UIImage imageNamed:@"ic_media_repeat_one"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void)updateShuffle:(BOOL)shuffle {
    self.shuffleButton.selected = shuffle;
}

// progress
- (void)updateProgressingTime:(float)value maxValue:(float)maxValue minValue:(float)minValue {
    _progressSlider.minimumValue = 0;
    _progressSlider.maximumValue = maxValue;
    _progressSlider.value = value;
    
    _currentTimeLabel.text = [self formatStringWithSeconds:(int)value];
    _maxTimeLabel.text = [self formatStringWithSeconds:(int)maxValue];
}

#pragma mark - Actions from controls
- (IBAction)playButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:PlayerActionPlay optionValue:0];
    }
}

- (IBAction)nextButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:PlayerActionNext optionValue:0];
    }
}

- (IBAction)prevButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:PlayerActionPrevious optionValue:0];
    }
}

- (IBAction)shuffleButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:PlayerActionShuffle optionValue:0];
    }
}

- (IBAction)repeatButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:PlayerActionRepeat optionValue:0];
    }
}

- (IBAction)volumnSliderValueChanged:(UISlider *)sender {
    if ([self p_isActionResponsable]) {
        Float32 value = sender.value / sender.maximumValue;
        
        [_delegate playerView:self performAction:PlayerActionVolumnChanged optionValue:value];
    }
}

- (IBAction)progressSliderValueChanged:(UISlider *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:PlayerActionProgressChanged optionValue:sender.value];
    }
}

- (IBAction)addPlaylistButtonSelected:(id)sender {
    if ([self p_isMediaActionResponsable]) {
        [_delegate playerView:self performMediaAction:MediaActionAddPlaylist];
    }
}

- (IBAction)addFavouriteButtonSelected:(id)sender {
    if ([self p_isMediaActionResponsable]) {
        [_delegate playerView:self performMediaAction:MediaActionAddFavourite];
    }
}

- (IBAction)downloadButtonSelected:(id)sender {
    if ([self p_isMediaActionResponsable]) {
        [_delegate playerView:self performMediaAction:MediaActionDownload];
    }
}

- (IBAction)shareButtonSelected:(id)sender {
    if ([self p_isMediaActionResponsable]) {
        [_delegate playerView:self performMediaAction:MediaActionSharing];
    }
}

@end
