//
//  MiniPlayerView.m

//
//  Created by Toan Nguyen on 11/30/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "MiniPlayerView.h"

@interface MiniPlayerView(){
    NSTimer *_timer;
}

- (void)p_displayInformation:(AudioItem *)item;

@property (weak, nonatomic) IBOutlet UIView *thumbnailBgrView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation MiniPlayerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializeSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeSubviews];
    }
    return self;
}

- (void)initializeSubviews {
    NSString *className = NSStringFromClass([self class]);
    
    [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    
    [self addSubview:self.view];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeTop]];
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeLeft]];
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeBottom]];
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeRight]];
}

- (NSLayoutConstraint *)pin:(id)item attribute:(NSLayoutAttribute)attribute {
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:item
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowRadius = 2;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidStartPlayingItem:) name:kNotification_AudioPlayerDidStartPlayingItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateChanged:) name:kNotification_AudioPlayerStateChanged object:nil];
    [self setupTimer];
    
    [self p_displayInformation:[AudioPlayer shared].currentItem];
    [self updateControls];
}

#pragma mark - Private methods
- (void)p_displayInformation:(AudioItem *)item {
    self.titleLabel.text = item.name ? item.name : @"Unknow";
    self.detailLabel.text = item.detail ? item.detail : @"Unknow";
}

- (void)setupTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)timerTick {
    AudioPlayer *player = [AudioPlayer shared];
    if (player.currentItem && player.duration != 0) {
        _progressViewWidthConstraint.constant = (player.progress/player.duration) * self.bounds.size.width;
    }else {
        _progressViewWidthConstraint.constant = 0;
    }
    
    [self layoutIfNeeded];
}

- (void)updateControls {
    AudioPlayer *player = [AudioPlayer shared];
    if (player.state == STKAudioPlayerStatePlaying || player.state == STKAudioPlayerStateBuffering) {
        [self.playPauseButton setImage:[UIImage imageNamed:@"ic_mini_player_pause"] forState:UIControlStateNormal];
    } else {
        [self.playPauseButton setImage:[UIImage imageNamed:@"ic_mini_player_start"] forState:UIControlStateNormal];
    }
}

- (void)runPlayingAnimation:(BOOL)playing {
    _thumbnailBgrView.layer.sublayers = nil;

    if (playing) {
        CGSize thumbnailSize = _thumbnailBgrView.bounds.size;
        CGSize startSize = CGSizeMake(0.5 * thumbnailSize.width, 0.5 * thumbnailSize.height);
        
        for (int i = 0; i < 2; i++) {
            CAShapeLayer *circle = [[CAShapeLayer alloc] init];
            circle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-startSize.width/2, -startSize.height/2, startSize.width, startSize.height)].CGPath;
            circle.fillColor = [UIColor whiteColor].CGColor;
            circle.position = CGPointMake(thumbnailSize.width/2, thumbnailSize.height/2);
            circle.opacity = 0;
            [self.thumbnailBgrView.layer addSublayer:circle];
            
            CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnim.fromValue = @(0.3);
            opacityAnim.toValue = @(0.0);
            
            CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
            scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];
            CAAnimationGroup *anim = [[CAAnimationGroup alloc] init];
            anim.animations = @[opacityAnim, scaleAnim];
            anim.repeatCount = HUGE_VALF;
            anim.duration = 2;
            anim.beginTime = CACurrentMediaTime() + i;
            anim.removedOnCompletion = NO;
            [circle addAnimation:anim forKey:@"group"];
        }
    }
}

#pragma mark - Handle events
- (IBAction)playPauseButtonSelected:(UIButton *)sender {
    AudioPlayer *player = [AudioPlayer shared];
    if (player.state == STKAudioPlayerStatePlaying || player.state == STKAudioPlayerStateBuffering) {
        [player pause];
        [self runPlayingAnimation:NO];
    } else {
        [player resume];
        [self runPlayingAnimation:YES];
    }
}

- (IBAction)tapOnNextButton:(id)sender {
    [[AudioPlayer shared] next];
}

- (IBAction)tapOnBackButton:(id)sender {
    [[AudioPlayer shared] previous];
}

#pragma mark - AudioPlayerListener

- (void)playerDidStartPlayingItem:(NSNotification *)notification {
    AudioItem *item = (AudioItem *)notification.object;
    [self p_displayInformation:item];
    [self runPlayingAnimation:YES];
}

- (void)playerStateChanged:(NSNotification *)notification{
    [self updateControls];
}
@end
