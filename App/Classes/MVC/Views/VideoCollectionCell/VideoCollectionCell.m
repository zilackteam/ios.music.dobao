//
//  VideoCollectionCell.m
//  music.application
//
//  Created by thanhvu on 3/19/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "VideoCollectionCell.h"
#import "Video.h"

@implementation VideoCollectionCell

@synthesize imageView = _imageView;
@synthesize titleView = _titleView;
@synthesize detailView = _detailView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        _imageView.layer.cornerRadius = 5.0;
    }
    return self;
}

- (void)p_setImageUrl:(NSURL *)url {
    [_imageView sd_setImageWithURL:url
                  placeholderImage:[UIImage imageNamed:@"placeholder_mini"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                      if (image) {
                          [UIView transitionWithView:_imageView
                                            duration:0.5
                                             options:UIViewAnimationOptionTransitionCrossDissolve
                                          animations:^{
                                              _imageView.image = image;
                                          } completion:nil];
                      }
    }];
}

- (void)setItem:(id<MediaItem>)item {
//    _imageView.alpha = 0;
    if (item) {
//        [self p_setImageUrl:item.thumbnailUrl];
        
        [self performSelector:@selector(p_setImageUrl:) withObject:[NSURL URLWithString:item.thumbUrl]];
        _titleView.text = item.name;
        _detailView.text = item.detail;
    }
}

- (void)setItem:(id<MediaItem>)item useFeature:(BOOL)feature {
    if (item) {
        [self performSelector:@selector(p_setImageUrl:) withObject:[NSURL URLWithString:item.featureUrl]];
        
        _titleView.text = item.name;
        _detailView.text = item.detail;
    }
}

- (void)setValue:(id<BaseObject>)object {
//    _imageView.alpha = 0;
    Video *video = (Video *)object;
    if (video.thumbUrl) {
//        [self p_setImageUrl:video.thumbnailUrl];
        [self performSelector:@selector(p_setImageUrl:) withObject:[NSURL URLWithString:video.thumbUrl]];
    }
    
    _titleView.text = video.name?video.name:@"";
    _detailView.text = video.performer?video.performer:@"";
}
@end
