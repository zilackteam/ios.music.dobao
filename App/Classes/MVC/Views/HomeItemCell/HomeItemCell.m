//
//  HomeItemCell.m
//  music.application
//
//  Created by thanhvu on 3/17/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeItemCell.h"

@interface HomeItemCell()

- (void)p_setItem:(id<MediaItem>)item useFeature:(BOOL)feature;
@end

@implementation HomeItemCell
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

- (void)p_setItem:(id<MediaItem>)item useFeature:(BOOL)feature {
    if (item) {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:feature?item.featureUrl:item.thumbUrl]
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
        
        _titleView.text = item.name;
        _detailView.text = item.detail;
    }
}
- (void)setItem:(id<MediaItem>)item {
    [self p_setItem:item useFeature:NO];
}

- (void)setItem:(id<MediaItem>)item useFeature:(BOOL)feature {
    [self p_setItem:item useFeature:feature];
}

@end
