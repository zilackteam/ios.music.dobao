//
//  AlbumHeaderReusableView.m
//  music.application
//
//  Created by thanhvu on 3/28/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "AlbumHeaderReusableView.h"
@interface AlbumHeaderReusableView()
@property (weak, nonatomic) IBOutlet UIView *groundView;

@end
@implementation AlbumHeaderReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
/*
        _groundView.layer.shadowColor = RGBA(175, 68, 118, 0.5).CGColor;
        _groundView.layer.shadowOpacity = 0.2;
        _groundView.layer.shadowOffset = CGSizeMake(0, 4);
*/
    }
    return self;
}

@end
