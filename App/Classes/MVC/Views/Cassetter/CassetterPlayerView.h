//
//  CassetterPlayerView.h
//  music.dobao
//
//  Created by thanhvu on 7/11/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, CassetterPlayState)
{
    CassetterPlayReady,
    CassetterPlayPlaying,
    CassetterPlayBuffering,
    CassetterPlayRunning,
    CassetterPlayPaused,
    CassetterPlayStopped
};

typedef NS_OPTIONS(NSInteger, CassetterPlayAction)
{
    CassetterPlayActionPlay,
    CassetterPlayActionPause,
    CassetterPlayActionNext,
    CassetterPlayActionPrevious,
    CassetterPlayActionRepeat,
    CassetterPlayActionShuffle,
    CassetterPlayActionVolumnChanged,
    CassetterPlayActionProgressChanged
};

@class CassetterPlayerView;
@protocol CassetterPlayerViewDelegate <NSObject>

@required
- (void)playerView:(CassetterPlayerView *)view performAction:(CassetterPlayAction) action optionValue:(float)value;
@end

@interface CassetterPlayerView : UIView

// delegate
@property (weak, nonatomic) id<CassetterPlayerViewDelegate> delegate;

// Information for playing
- (void)updatePlayInfomation:(NSString *)name detail:(NSString *)detail;

- (void)updatePlayInfomation:(NSString *)name detail:(NSString *)detail duration:(int)duration track:(NSInteger)trackIdx totalList:(NSInteger)total;

// Player state
- (void)updatePlayerState:(CassetterPlayState) state;

// Volumn
- (void)updateVolumn:(float)value;

// Loop
- (void)updateLoopState:(AudioPlayerLoopType)type;

// shuffle
- (void)updateShuffle:(BOOL)shuffle;

// Progress
- (void)updateProgressingTime:(float)value maxValue:(float)maxValue minValue:(float)minValue;

@end
