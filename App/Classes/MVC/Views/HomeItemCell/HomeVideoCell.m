//
//  HomeVideoCell.m
//  music.application
//
//  Created by thanhvu on 3/19/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeVideoCell.h"

@interface HomeVideoCell()
- (void)p_setItem:(id<MediaItem>)item useFeature:(BOOL)feature;
@end

@implementation HomeVideoCell
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
    }
    return self;
}

- (void)p_setItem:(id<MediaItem>)item useFeature:(BOOL)feature {
    if (item) {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:item.featureUrl?item.featureUrl:item.thumbUrl]
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
    [self p_setItem:item useFeature:YES];
}

@end
