//
//  TitleView.m
//  music.thuphuong
//
//  Created by thanhvu on 8/14/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "TitleView.h"

@interface TitleView()
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation TitleView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setIcon:(UIImage *)image {
    _iconView.image = image;
}

@end
