//
//  PlayingViewCell.h
//  music.application
//
//  Created by thanhvu on 3/25/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaActionManager.h"

typedef NS_OPTIONS(NSInteger, PlayerState)
{
    PlayerStateReady,
    PlayerStatePlaying,
    PlayerStateBuffering,
    PlayerStatePaused,
    PlayerStateStopped
};

typedef NS_OPTIONS(NSInteger, PlayerAction)
{
    PlayerActionPlay,
    PlayerActionNext,
    PlayerActionPrevious,
    PlayerActionRepeat,
    PlayerActionShuffle,
    PlayerActionVolumnChanged,
    PlayerActionProgressChanged
};

@class PlayingViewCell;
@protocol PlayingViewCellDelegate <NSObject>

@required
- (void)playerView:(PlayingViewCell *)view performAction:(PlayerAction) action optionValue:(float)value;
- (void)playerView:(PlayingViewCell *)view performMediaAction:(MediaActionType)action;

@end

@interface PlayingViewCell : UICollectionViewCell

// delegate
@property (weak, nonatomic) id<PlayingViewCellDelegate> delegate;

// Information for playing
- (void)updatePlayInfomation:(NSString *)name detail:(NSString *)detail;

- (void)updatePlayInfomation:(NSString *)name detail:(NSString *)detail favourite:(BOOL)favourite;

// Player state
- (void)updatePlayerState:(PlayerState) state;

// Volumn
- (void)updateVolumn:(float)value;

// Loop
- (void)updateLoopState:(AudioPlayerLoopType)type;

// shuffle
- (void)updateShuffle:(BOOL)shuffle;

// Progress
- (void)updateProgressingTime:(float)value maxValue:(float)maxValue minValue:(float)minValue;
@end
