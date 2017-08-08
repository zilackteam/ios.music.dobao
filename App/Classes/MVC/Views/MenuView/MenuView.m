//
//  MenuView.m

//
//  Created by thanhvu on 12/3/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "MenuView.h"

@interface MenuView()<MenuViewDataSource>

@end

@implementation MenuView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - MenuViewDataSource
- (void)menuView:(AppMenuView *)view indicatorView:(UIView *)indicatorView {
    indicatorView.backgroundColor = [UIColor colorWithRed:254/255.0 green:132/255.0 blue:69/255.0 alpha:1];
}

- (UIColor *)menuViewItemNormalColor {
    return [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1];
}

- (UIColor *)menuViewItemSelectedColor {
    return [UIColor colorWithRed:254/255.0 green:132/255.0 blue:69/255.0 alpha:1];
}

@end
