//
//  PlaylistSongCollectionViewCell.m
//  music.application
//
//  Created by thanhvu on 3/20/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "PlaylistSongCollectionViewCell.h"

@implementation PlaylistSongCollectionViewCell

@synthesize imageView = _imageView;
@synthesize titleView = _titleView;
@synthesize detailView = _detailView;
//@synthesize statusButton = _statusButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)setItem:(id<MediaItem>)item {
    [super setItem:item];
}

- (void)setValue:(id<BaseObject>)object {
    if (_imageView) {
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage imageNamed:@"ic_song_bgr"];
    }
    
    id obj = object;
    
    NSString *name = [obj valueForKey:@"name"];
    _titleView.text = name?name:@"";
    
    NSString *performer = [obj valueForKey:@"performer"];
    _detailView.text = performer?performer:@"";
}

- (void)setItemNo:(NSInteger)no {
    [_statusButton setTitle:[NSString stringWithFormat:@"%ld", (long)no] forState:UIControlStateNormal];
}

- (void)setPlayingState:(BOOL)playing {
    if (!playing) {
        if (_imageView) {
            _imageView.image = nil;
        }
        _statusButton.alpha = 1;
    } else {
        [UIView transitionWithView:_imageView
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            _statusButton.alpha = 0;
                            _imageView.image = [UIImage imageNamed:@"ic_media_pause_hl"];
                        } completion:nil];
    }
}

@end
