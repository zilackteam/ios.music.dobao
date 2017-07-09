//
//  MenuCollectionCell.m
//  music.application
//
//  Created by thanhvu on 3/21/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "MenuCollectionCell.h"

@implementation MenuCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_menu_background_selected"]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedMenuCollectionCell:)]) {
        [_delegate didSelectedMenuCollectionCell:self];
    }
}

@end
