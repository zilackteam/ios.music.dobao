//
//  MenuCollectionCell.m
//  music.application
//
//  Created by thanhvu on 3/21/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "MenuCollectionCell.h"

@interface MenuCollectionCell()<MenuCollectionCellDataSource>

@end
@implementation MenuCollectionCell
- (UIView *)menuSelectedBackgroundView {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_menu_background_selected"]];
}
@end
