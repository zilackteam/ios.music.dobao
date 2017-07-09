//
//  VideoDetailCollectionViewController.m
//  music.application
//
//  Created by thanhvu on 5/16/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "VideoDetailCollectionViewController.h"
#import "VideoCollectionCell.h"
#import "Video.h"
#import "AppDelegate.h"
#import "ZLRoundButton.h"
#import "MusicStoreManager.h"
#import "VideoEntity+CoreDataClass.h"

#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MPMoviePlayerController+BackgroundPlayback.h"

#define PLAY_IMAGE_PAUSE            [UIImage imageNamed:@"ic_media_pause_hl"]
#define PLAY_IMAGE_PLAY             [UIImage imageNamed:@"ic_media_play_hl"]

@interface MoviePlayButton()
@end

@implementation MoviePlayButton
@synthesize buttonState = _state;

- (void)awakeFromNib {
    [super awakeFromNib];
    _state = MoviePlayButtonStatePause;
}

- (void)updatePlaybackState:(MPMoviePlaybackState)state {
    switch (state) {
        case MPMoviePlaybackStatePlaying: {
            [self setImage:PLAY_IMAGE_PAUSE forState:UIControlStateNormal];
            _state = MoviePlayButtonStatePause;
        }
            break;
        case MPMoviePlaybackStateStopped: {
            [self setImage:PLAY_IMAGE_PLAY forState:UIControlStateNormal];
            _state = MoviePlayButtonStatePlay;
        }
            break;
        case MPMoviePlaybackStatePaused: {
            [self setImage:PLAY_IMAGE_PLAY forState:UIControlStateNormal];
            _state = MoviePlayButtonStatePlay;
        }
            break;
        case MPMoviePlaybackStateInterrupted:
            [self setImage:PLAY_IMAGE_PLAY forState:UIControlStateNormal];
            _state = MoviePlayButtonStatePlay;
            break;
        case MPMoviePlaybackStateSeekingForward:
            [self setImage:PLAY_IMAGE_PAUSE forState:UIControlStateNormal];
            _state = MoviePlayButtonStatePause;
            break;
        case MPMoviePlaybackStateSeekingBackward:
            [self setImage:PLAY_IMAGE_PAUSE forState:UIControlStateNormal];
            _state = MoviePlayButtonStatePause;
            break;
        default:
            break;
    }
}

- (MoviePlayButtonState)buttonState {
    return _state;
}

@end

@interface VideoActionView()

@property (nonatomic, weak) IBOutlet ZLRoundButton *favouriteButton;
@end

@implementation VideoActionView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.alpha = 0;
    self.state = ActionViewStateHidden;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.alpha = 0;
        self.state = ActionViewStateHidden;
    }
    return self;
}

- (void)setState:(ActionViewState)state {
    _state = state;
    float alpha = 0.0f;
    switch (_state) {
        case ActionViewStateHidden:
            alpha = 0;
            break;
        case ActionViewStateShow:
            alpha = 1;
        default:
            break;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = alpha;
    }];
}

- (void)updateFavouriteSelected:(BOOL)favourited {
    _favouriteButton.selected = favourited;
}

- (IBAction)favouriteButtonSelected:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(videoActionView:performAction:)]) {
        [_delegate videoActionView:self performAction:MediaActionAddFavourite];
    }
}

- (IBAction)shareButtonSelected:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(videoActionView:performAction:)]) {
        [_delegate videoActionView:self performAction:MediaActionSharing];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setState:ActionViewStateHidden];
}

@end

@interface VideoDetailCollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, MediaBaseCellDelegate, VideoActionViewDelegate>

@property (weak, nonatomic) IBOutlet MoviePlayButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *featureButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingStatusView;
@property (weak, nonatomic) IBOutlet VideoActionView *actionView;

- (IBAction)zoomButtonSelected:(id)sender;

@property (strong, nonatomic) VideoList *itemList;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, weak) XCDYouTubeVideoPlayerViewController *playerViewController;

- (void)p_onPlay;
- (NSString *)p_extractYoutubeIdFromLink:(NSString *)link;

@end

@implementation VideoDetailCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self useMainBackground];
    [self setLeftNavButton:Back];
    
    _actionView.delegate = self;
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 25;
    currentLayout.minimumInteritemSpacing = 10;
    
    CGFloat edge = 10;
    currentLayout.sectionInset = UIEdgeInsetsMake(edge, edge, edge, edge);
    
    [currentLayout invalidateLayout];
    [[AppDelegate sharedInstance] musicStop];
    
    [self p_onPlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)p_onPlay {
    Video *video = [_itemList itemAtIndex:_selectedIndex];
    if (!video || !video.path) {
        return;
    }
    
    NSInteger identifier = video.identifier;
    id videoEntity = [[MusicStoreManager sharedManager] videoByIdentify:identifier];
    if (videoEntity) {
        [_actionView updateFavouriteSelected:YES];
    } else {
        [_actionView updateFavouriteSelected:NO];
    }
    
    self.title = video.name;
    
    if (_playerViewController) {
        [_playerViewController.moviePlayer stop];
    }
    
    _progressView.progress = 0.01;
    
    [self.videoContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSString *yId = [self p_extractYoutubeIdFromLink:video.path];
    
    _playerViewController = [[AppDelegate sharedInstance] videoPlayerViewControllerWithIdentifier:yId];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_playerViewController.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:_playerViewController.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayWillExitFullscreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:_playerViewController.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayDidEnterFullscreen:)
                                                 name:MPMoviePlayerDidEnterFullscreenNotification
                                               object:_playerViewController.moviePlayer];

    [_playerViewController presentInView:_videoContainerView];
    // hiden all control
    _playerViewController.moviePlayer.controlStyle = MPMovieControlStyleNone;
    // show loading
    [_loadingStatusView startAnimating];
    // prepare play
    [_playerViewController.moviePlayer prepareToPlay];
}

#pragma mark - Movie Player Notification
- (void)moviePlayLoadStateDidChange:(NSNotification *)notification {
    MPMoviePlayerController *moviePlayer = notification.object;
    MPMovieLoadState state = moviePlayer.loadState;
    
    switch (state) {
        case MPMovieLoadStateUnknown:
            break;
        case MPMovieLoadStateStalled:
            break;
        case MPMovieLoadStatePlayable:
            // show loading
            [_loadingStatusView stopAnimating];
            [moviePlayer prepareToPlay];
            break;
        case MPMovieLoadStatePlaythroughOK:
            [_loadingStatusView stopAnimating];
            break;
        default:
            break;
    }
}

- (void)moviePlaybackStateDidChange:(NSNotification *)notification {
    MPMoviePlayerController *moviePlayer = notification.object;
    MPMoviePlaybackState state = moviePlayer.playbackState;
    
    if (state == MPMoviePlaybackStatePlaying && moviePlayer.duration > 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            _progressView.progress = moviePlayer.currentPlaybackTime/moviePlayer.duration;
        }];
    } else {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }
    
    [_playButton updatePlaybackState:state];
}

- (void)moviePlayWillExitFullscreen:(NSNotification *)notification {
    _playerViewController.moviePlayer.controlStyle = MPMovieControlStyleNone;
}

- (void)moviePlayDidEnterFullscreen:(NSNotification *)notification {
    _playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
}


- (NSString *)p_extractYoutubeIdFromLink:(NSString *)link {
    NSString *regexString = @"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    
    NSArray *array = [regExp matchesInString:link options:0 range:NSMakeRange(0,link.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange:result.range];
    }
    return nil;
}

- (void)setVideoList:(VideoList *)videoList {
    _itemList = videoList;
}

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_itemList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"video_cell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell setItem:[_itemList itemAtIndex:indexPath.item]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellCount = 2;
    CGFloat w = (_collectionView.bounds.size.width - (cellCount + 1) * 10) / cellCount;
    CGFloat h = w/2.0 + 50;
    return CGSizeMake(w, h);
}

- (void)didSelectedCell:(MediaBaseCell *)cell {
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    
    _selectedIndex = indexPath.item;
    
    [self p_onPlay];
}

#pragma mark - Actions
- (IBAction)zoomButtonSelected:(id)sender {
    [_playerViewController.moviePlayer setFullscreen:YES animated:YES];
}

- (IBAction)playButtonSelected:(id)sender {
    switch (_playButton.buttonState) {
        case MoviePlayButtonStatePause: // playing
            [_playerViewController.moviePlayer pause];
            break;
        case MoviePlayButtonStatePlay: // paused
            [_playerViewController.moviePlayer play];
            break;
        default:
            break;
    }
}

- (IBAction)actionButtonSelected:(id)sender {
    if (_actionView.state == ActionViewStateHidden) {
        [_actionView setState:ActionViewStateShow];
    } else {
        [_actionView setState:ActionViewStateHidden];
    }
}

#pragma mark - VideoActionViewDelegate
- (void)videoActionView:(VideoActionView *)view performAction:(MediaActionType)action {
    [view setState:ActionViewStateHidden];
    switch (action) {
        case MediaActionAddFavourite: {
            Video *video = [_itemList itemAtIndex:_selectedIndex];
            if (!video) {
                return;
            }
            
            NSInteger identifier = video.identifier;
            id videoObject = [[MusicStoreManager sharedManager] videoByIdentify:identifier];
            if (videoObject) {
                [_actionView updateFavouriteSelected:NO];
                [[MusicStoreManager sharedManager] deleteObject:videoObject];
            } else {
                [_actionView updateFavouriteSelected:YES];
                id videoEntity = [[MusicStoreManager sharedManager] managedObjectClass:[VideoEntity class]];
                if (videoEntity) {
                    [[MusicStoreManager sharedManager] copyPropertiesValueObject:video toEntity:videoEntity];
                }
                
                [[MusicStoreManager sharedManager] commit];
            }
        }
            break;
        case MediaActionSharing:
            break;
        default:
            break;
    }
}

@end
