//
//  MenuCollectionCell.h
//  music.application
//
//  Created by thanhvu on 3/21/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuCollectionCell;
@protocol MenuCollectionCellDelegate <NSObject>
@optional
- (void)didSelectedMenuCollectionCell:(MenuCollectionCell *)cell;
- (void)willSelectedMenuCollectionCell:(MenuCollectionCell *)cell;
@end

@interface MenuCollectionCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) id<MenuCollectionCellDelegate> delegate;
@end
