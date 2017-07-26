//
//  VideoDetailCollectionViewController.h
//  music.application
//
//  Created by thanhvu on 5/16/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "BaseViewController.h"
#import "VideoList.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MediaActionManager.h"

typedef NS_OPTIONS(NSInteger, MoviePlayButtonState) {
    MoviePlayButtonStatePause,
    MoviePlayButtonStatePlay
};
@interface MoviePlayButton : UIButton

- (void)updatePlaybackState:(MPMoviePlaybackState)state;

@property (nonatomic, readonly) MoviePlayButtonState buttonState;

@end

typedef NS_OPTIONS(NSInteger, ActionViewState) {
    ActionViewStateHidden,
    ActionViewStateShow
};

@class VideoActionView;
@protocol VideoActionViewDelegate <NSObject>
- (void)videoActionView:(VideoActionView *)view performAction:(MediaActionType) action;
@end

@interface VideoActionView : UIView
@property (nonatomic, assign, readonly) ActionViewState state;
@property (nonatomic, weak) id<VideoActionViewDelegate> delegate;

- (void)updateFavouriteSelected:(BOOL)favourited;

@end

@interface VideoDetailCollectionViewController : BaseViewController

@property (nonatomic, assign) NSInteger selectedIndex;

- (void)setList:(VideoList*)videoList;

@end
