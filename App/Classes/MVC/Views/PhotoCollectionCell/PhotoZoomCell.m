//
//  PhotoZoomCell.h
//  Singer-Thuphuong
//
//  Created by thanhvu on 10/18/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "PhotoZoomCell.h"

@implementation PhotoZoomCell

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        _imageView.alpha = .7f;
    }else {
        _imageView.alpha = 1.f;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _scrollView.clipsToBounds = YES;
    _imageView.clipsToBounds = YES;
    _imageView.alpha = 1;
    
    [_scrollView setScrollEnabled:YES];
    [_scrollView setUserInteractionEnabled:YES];
    [_scrollView setMinimumZoomScale:1.0f];
    [_scrollView setMaximumZoomScale:3.0f];
    _scrollView.delegate = self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)setImageUrl:(NSString *)url {
    if (url) {
        [_activityView startAnimating];
        _imageView.alpha = 0;
        [_imageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    _imageView.alpha = 1;
                    [_activityView stopAnimating];
                }];
                
            });
        }];
    }
}

- (void)prepareForReuse {
    _imageView.image = nil;
    [_activityView stopAnimating];
    [_scrollView setZoomScale:1.0];
}

@end
