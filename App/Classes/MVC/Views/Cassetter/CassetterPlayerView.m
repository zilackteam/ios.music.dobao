//
//  CassetterPlayerView.m
//  music.dobao
//
//  Created by thanhvu on 7/11/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "CassetterPlayerView.h"

@interface CassetterPlayerView()

@property (nonatomic, weak) IBOutlet UIImageView *gearLeft;
@property (nonatomic, weak) IBOutlet UIImageView *gearRight;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;

@property (weak, nonatomic) IBOutlet UIView *leftCircleContainer;
@property (weak, nonatomic) IBOutlet UIView *rightCircleContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rollRightWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rollLeftWidthConstraint;

- (void)p_rotate;

- (void)p_stop;

@end

@implementation CassetterPlayerView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self p_rotate];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_rotate];
    }
    
    return self;
}

- (void)p_rotate {
    dispatch_async(dispatch_get_main_queue(), ^{
        CABasicAnimation *fullRotation;
        fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        fullRotation.fromValue = [NSNumber numberWithFloat:0];
        fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
        fullRotation.duration = 8;
        fullRotation.repeatCount = HUGE_VALF;
        
        [_leftCircleContainer.layer addAnimation:fullRotation forKey:@"360"];
        [_rightCircleContainer.layer addAnimation:fullRotation forKey:@"360"];
        
        [_gearLeft.layer addAnimation:fullRotation forKey:@"360"];
        [_gearRight.layer addAnimation:fullRotation forKey:@"360"];
        
    });
}

- (void)p_stop {
    [_gearLeft.layer removeAllAnimations];
    [_gearRight.layer removeAllAnimations];
    [_leftCircleContainer.layer removeAllAnimations];
    [_rightCircleContainer.layer removeAllAnimations];
}


// Information for playing
- (void)updatePlayInfomation:(NSString *)name detail:(NSString *)detail {
    _nameLabel.text = name;
    _detailLabel.text = detail;
}

- (void)updatePlayInfomation:(NSString *)name detail:(NSString *)detail duration:(int)duration track:(NSInteger)trackIdx totalList:(NSInteger)total {
    [self updatePlayInfomation:name detail:detail];
    
    _maxTimeLabel.text = [@"Time: " stringByAppendingString:[self formatStringWithSeconds:duration]];
    _trackLabel.text = [NSString stringWithFormat:@"Track %ld of %ld", (long)trackIdx, (long)total];
}

// Player state
- (void)updatePlayerState:(CassetterPlayState) state {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_pauseButton setSelected:NO];
        switch (state) {
            case CassetterPlayBuffering:
                [_playButton setSelected:YES];
                break;
            case CassetterPlayPaused:
                [_playButton setSelected:NO];
                [_pauseButton setSelected:YES];
                break;
            case CassetterPlayRunning:
                break;
            case CassetterPlayStopped:
                [_playButton setSelected:NO];
                break;
            case CassetterPlayReady:
                break;
            case CassetterPlayPlaying:
                [_playButton setSelected:YES];
                break;
            default:
                break;
        }
    });
}

// Volumn
- (void)updateVolumn:(float)value {
    
}

// Loop
- (void)updateLoopState:(AudioPlayerLoopType)type {
    
}

// shuffle
- (void)updateShuffle:(BOOL)shuffle {
    
}

// Progress
- (void)updateProgressingTime:(float)value maxValue:(float)maxValue minValue:(float)minValue {
    if (maxValue == 0) {
        _rollLeftWidthConstraint.constant = 100.0;
        _rollLeftWidthConstraint.constant = 0.0;
    } else {
        _rollLeftWidthConstraint.constant = ((maxValue - value)/maxValue) * 100;
        _rollRightWidthConstraint.constant = (value/maxValue) * 100;
    }
    
    [self layoutIfNeeded];
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

#pragma mark - Actions from controls
- (IBAction)playButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:CassetterPlayActionPlay optionValue:0];
    }
}

- (IBAction)pauseButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:CassetterPlayActionPause optionValue:0];
    }
}

- (IBAction)nextButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:CassetterPlayActionNext optionValue:0];
    }
}

- (IBAction)prevButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:CassetterPlayActionPrevious optionValue:0];
    }
}

- (IBAction)shuffleButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:CassetterPlayActionShuffle optionValue:0];
    }
}

- (IBAction)repeatButtonSelected:(UIButton *)sender {
    if ([self p_isActionResponsable]) {
        [_delegate playerView:self performAction:CassetterPlayActionRepeat optionValue:0];
    }
}

@end
