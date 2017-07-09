//
//  FullPlayerViewController.m
//  music.application
//
//  Created by thanhvu on 3/25/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "FullPlayerViewController.h"
#import "PlaylistCollectionViewController.h"
#import "PlayingViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PlayingPlaylistViewCell.h"
#import "SongEntity+CoreDataClass.h"
#import "AppDelegate.h"

enum PlayerIndex {
    PlayerIndexList     = 0,
    PlayerIndexPlaying  = 1,
    PlayerIndexLyrics   = 2
} PlayerIndex;

@interface LyricsViewCell()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end

@implementation LyricsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor blackColor];
    _textView.editable = NO;
    _textView.selectable = NO;
    _textView.backgroundColor = self.backgroundColor;
    _textView.textColor = RGB(136, 136, 136);
}

- (void)updateLyrics:(NSString *)lyrics {
    _textView.editable = NO;
    _textView.selectable = NO;
    _textView.text = lyrics;
    _textView.textColor = RGB(136, 136, 136);
    
    CGSize sizeThatFitsTextView = [_textView sizeThatFits:CGSizeMake(_textView.frame.size.width, MAXFLOAT)];
    
    _heightConstraint.constant = MIN(sizeThatFitsTextView.height + 100.0f, self.frame.size.height - 64);
}

@end

@interface FullPlayerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, PlayingViewCellDelegate, PlaylistCollectionViewControllerDelegate>
{
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

- (PlayingViewCell *)playingCell;

@end

@implementation FullPlayerViewController
- (void)dealloc {
    [_timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // clear background for navigationbar
    [_navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    _navigationBar.shadowImage = [UIImage new];
    _navigationBar.translucent = YES;
    _navigationBar.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidStartPlayingItem:) name:kNotification_AudioPlayerDidStartPlayingItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateChanged:) name:kNotification_AudioPlayerStateChanged object:nil];
//  back
    UIImage *img = [UIImage imageNamed:@"ic_navigation_back"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:img forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [button addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    _navigationItem.leftBarButtonItem = barItem;
//
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 0;
    currentLayout.minimumInteritemSpacing = 0;
    CGFloat edge = 0;
    currentLayout.sectionInset = UIEdgeInsetsMake(edge, edge, edge, edge);
    
    [currentLayout invalidateLayout];
    
    [self setupTimer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Only scroll when the view is rendered for the first time
    
    CGFloat pageWidth = self.collectionView.frame.size.width;
    CGPoint scrollTo = CGPointMake(pageWidth * 1, 0);
    
    [_collectionView setContentOffset:scrollTo animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateInformation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)onClose {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - AudioPlayerListener
- (void)playerDidStartPlayingItem:(NSNotification *)notification {
    
    NSIndexPath *indexPlayingPath = [NSIndexPath indexPathForItem:PlayerIndexPlaying inSection:0];
    
    NSArray *indexPaths = @[indexPlayingPath];
    
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    
    NSIndexPath *indexPlaylistPath = [NSIndexPath indexPathForItem:PlayerIndexList inSection:0];
    
    PlayingPlaylistViewCell *cell = (PlayingPlaylistViewCell *)[_collectionView cellForItemAtIndexPath:indexPlaylistPath];
    [cell updatePlayingState];
}

- (void)playerStateChanged:(NSNotification *)notification{
    [self updatePlayerStatus];
}

- (void)updateInformation {
    PlayingViewCell *playerUi = [self playingCell];
    [playerUi updatePlayInfomation:[[AudioPlayer shared].currentItem name] detail:[[AudioPlayer shared].currentItem detail]];
}

- (void)updatePlayerStatus {
    PlayingViewCell *playerUi = [self playingCell];
    
    AudioPlayer *player = [AudioPlayer shared];
    if (player.state == STKAudioPlayerStatePlaying || player.state == STKAudioPlayerStateBuffering) {
        [playerUi updatePlayerState:PlayerStatePlaying];
    } else {
        [playerUi updatePlayerState:PlayerStatePaused];
    }
}

- (void)setupTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)timerTick{
    AudioPlayer *player = [AudioPlayer shared];
    PlayingViewCell *playerUi = [self playingCell];
    
    if (playerUi) {
        if (player.currentItem) {
            [playerUi updateProgressingTime:player.progress maxValue:player.duration minValue:0];
        } else {
            [playerUi updateProgressingTime:0 maxValue:0 minValue:0];
        }
    }
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.item) {
        case PlayerIndexList: {
            PlayingPlaylistViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"playlist_cell" forIndexPath:indexPath];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell updatePlayingState];
            return cell;
        }
            break;
        case PlayerIndexPlaying: {
            PlayingViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"playing_cell" forIndexPath:indexPath];
            [cell setBackgroundColor:[UIColor clearColor]];
            cell.delegate = self;
            
            // default
            { // default setting
                AudioPlayer *player = [AudioPlayer shared];
                id entity = [[MusicStoreManager sharedManager] songByIdentify:player.currentItem.identifier mode:Data_OnlineFavourite];
                
                [cell updatePlayInfomation:[player.currentItem name] detail:[player.currentItem detail] favourite:entity?YES:NO];
                [cell updateLoopState:[player loopType]];
                [cell updateShuffle:[player shuffle]];
                [cell updateVolumn:player.volume];
                if (player.state == STKAudioPlayerStatePlaying || player.state == STKAudioPlayerStateBuffering) {
                    [cell updatePlayerState:PlayerStatePlaying];
                } else {
                    [cell updatePlayerState:PlayerStatePaused];
                }
                
                [cell updateProgressingTime:player.progress maxValue:player.duration minValue:0];
            }
            return cell;
        }
            break;
        case PlayerIndexLyrics: {
            LyricsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lyrics_cell" forIndexPath:indexPath];
            [cell updateLyrics: [[AudioPlayer shared].currentItem lyrics]];
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size;
}

- (PlayingViewCell *)playingCell {
    return (PlayingViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
}

#pragma mark - PlayerViewCellDelegate
- (void)playerView:(PlayingViewCell *)view performAction:(PlayerAction)action optionValue:(float)value {
    AudioPlayer *player = [AudioPlayer shared];
    switch (action) {
        case PlayerActionPlay: {
            
            if (player.state == STKAudioPlayerStatePlaying || player.state == STKAudioPlayerStateBuffering) {
                [player pause];
            } else {
                [player resume];
            }
        }
            break;
        case PlayerActionNext: {
            [[AudioPlayer shared] next];
        }
            break;
        case PlayerActionPrevious: {
            [[AudioPlayer shared] previous];
        }
            break;
        case PlayerActionRepeat: {
            NSInteger type = player.loopType + 1;
            type = type > AudioPlayerLoopTypeAll ? AudioPlayerLoopTypeNone : type;
            [player setLoopType:(AudioPlayerLoopType)type];
            
            [[self playingCell] updateLoopState:(AudioPlayerLoopType)type];
        }
            break;
        case PlayerActionShuffle: {
            BOOL shuffle = ![player shuffle];
            [player setShuffle:shuffle];
            [[self playingCell] updateShuffle:shuffle];
        }
            break;
            
        case PlayerActionVolumnChanged: {
            player.volume = value;
        }
            break;
        case PlayerActionProgressChanged: {
            [player seekToOffset:value];
        }
            break;
        default:
            break;
    }
}

- (void)playerView:(PlayingViewCell *)view performMediaAction:(MediaActionType)action {
    AudioItem *currentItem = [[AudioPlayer shared] currentItem];
    switch (action) {
        case MediaActionDownload: {
            NSString *file = ([AppSettings musicQuality] == MusicQuality320)?[currentItem.information valueForKey:@"file320"]:[currentItem.information valueForKey:@"file128"];
            
            if (file) {
                [AppActions downloadSongInfo:currentItem.information];
            }
        }
            break;
        case MediaActionSharing: {
            [AppActions sharingFacebookWithTitle:currentItem.name description:nil link:APPLICATION_ITUNES_STORE_LINK];
        }
            break;
        case MediaActionAddFavourite:
        {
            NSInteger songIdentifier = [[currentItem.information valueForKey:@"identifier"] integerValue];
            
            id entity = [[MusicStoreManager sharedManager] songByIdentify:songIdentifier mode:Data_OnlineFavourite];
            if (entity) {
                [[MusicStoreManager sharedManager] deleteObject:entity];
            } else {
                id entity = [[MusicStoreManager sharedManager] songOnlineByIdentify:songIdentifier];
                
                if (entity) {
                    [entity setValue:@(Data_OnlineFavourite) forKey:@"flag"];
                } else {
                    entity = [[MusicStoreManager sharedManager] managedObjectClass:[SongEntity class]];
                    [((SongEntity *) entity) setOrderAt:[NSDate date]];
                    [[MusicStoreManager sharedManager] copyPropertiesValueObject:currentItem.information toEntity:entity];
                }
                
                [[MusicStoreManager sharedManager] commit];
            }
            
            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:PlayerIndexPlaying inSection:0]]];
        }
            break;
        case MediaActionAddPlaylist: {
            PlaylistCollectionViewController *vc = [UIStoryboard viewController:SB_PlaylistCollectionViewController storyBoard:StoryBoardMain];
            vc.dataMode = Data_OnlinePlaylist;
            [[[AppDelegate sharedInstance] topViewController] presentViewController:vc animated:NO completion:^{
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - PlaylistCollectionViewControllerDelegate
- (void)playlistCollectionViewController:(PlaylistCollectionViewController *)viewController didSelectedPlaylist:(PlaylistEntity *)playlist {
    [viewController dissmis:^{
        AudioItem *currentItem = [[AudioPlayer shared] currentItem];
        
        if (currentItem) {
            
            NSInteger identifier = [currentItem.information[@"identifier"] integerValue];
            SongEntity *entity = [[MusicStoreManager sharedManager] songOnlineByIdentify:identifier];
            
            if (entity == nil) {
                entity = [[MusicStoreManager sharedManager] managedObjectClass:[SongEntity class]];
                entity.flag = @(Data_OnlinePlaylist);
                
            } else if ([[playlist songs] containsObject:entity]) {
                [viewController dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            
            [[MusicStoreManager sharedManager] copyPropertiesValueObject:currentItem.information toEntity:entity];
            
            [playlist addSongsObject:entity];
            
            [[MusicStoreManager sharedManager] commit];
            [viewController dismissViewControllerAnimated:YES completion:^{
            }];
        }
    }];
}

@end
