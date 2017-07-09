//
//  AlbumCollectionCell.m
//  music.application
//
//  Created by thanhvu on 3/19/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "AlbumCollectionCell.h"
#import "Album.h"

@implementation AlbumCollectionCell
@synthesize imageView = _imageView;
@synthesize titleView = _titleView;
@synthesize detailView = _detailView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    _imageView.layer.cornerRadius = 5.0;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // _imageView.layer.cornerRadius = 5.0;
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
    if (item) {
        [self p_setImageUrl:[NSURL URLWithString:item.featureUrl?item.featureUrl:item.thumbUrl]];
        
        _titleView.text = item.name;
        _detailView.text = item.detail;
    }
}

- (void)setValue:(id<BaseObject>)object {
    Album *album = (Album *)object;
    
    [self p_setImageUrl:[NSURL URLWithString:album.thumbUrl]];
    _titleView.text = album.name?album.name:@"";
    _detailView.text = album.performer?album.performer:@"";
}

@end
