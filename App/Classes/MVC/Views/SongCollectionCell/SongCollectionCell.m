//
//  SongCollectionCell.m
//  music.application
//
//  Created by thanhvu on 3/19/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "SongCollectionCell.h"
#import "MediaAccessoryView.h"

@interface SongCollectionCell()
@end

@implementation SongCollectionCell

@synthesize imageView = _imageView;
@synthesize titleView = _titleView;
@synthesize detailView = _detailView;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)setItem:(id<MediaItem>)item {
    if (item) {
        _titleView.text = item.name;
        _detailView.text = item.detail;
    }
}

- (void)setValue:(id<BaseObject>)object {
    if (_imageView) {
        //_imageView.contentMode = UIViewContentModeCenter;
        _imageView.image = [UIImage imageNamed:@"ic_song_bgr"];
    }
    
    id obj = object;
    
    NSString *name = [obj valueForKey:@"name"];
    _titleView.text = name?name:@"";
    
    NSString *performer = [obj valueForKey:@"performer"];
    _detailView.text = performer?performer:@"";
}

- (void)setPlayingState:(BOOL)playing {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!playing) {
            _imageView.image = [UIImage imageNamed:@"ic_song_bgr"];
        } else {
            [UIView transitionWithView:_imageView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                _imageView.image = [UIImage imageNamed:@"ic_media_pause_hl"];
                            } completion:nil];
        }
    });
}


@end
