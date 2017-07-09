//
//  MenuHeaderReusableView.m
//  music.application
//
//  Created by thanhvu on 3/21/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "MenuHeaderReusableView.h"

@interface MenuHeaderReusableView()
@end

@implementation MenuHeaderReusableView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
/*
    if (_delegate && [_delegate respondsToSelector:@selector(menuHeaderResableView:selectedSection:)]) {
        [_delegate menuHeaderResableView:self selectedSection:_idx];
    }
*/
}

- (void)updateState:(MenuHeaderState)state {
/*
    [UIView animateWithDuration:0.5 animations:^{
        if (state == MenuHeaderState_Collapse) {
            _statusImage.image = [UIImage imageNamed:@"ic_menu_section_expand"];
        } else {
            _statusImage.image = [UIImage imageNamed:@"ic_menu_section_narrow"];
        }
    } completion:^(BOOL finished) {
    }];
*/
}

@end
