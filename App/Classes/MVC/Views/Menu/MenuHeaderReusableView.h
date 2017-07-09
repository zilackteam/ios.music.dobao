//
//  MenuHeaderReusableView.h
//  music.application
//
//  Created by thanhvu on 3/21/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuHeaderReusableView;

@protocol MenuHeaderReusableViewDelegate <NSObject>
- (void)menuHeaderResableView:(MenuHeaderReusableView *)headerReusableView selectedSection:(NSInteger)index;
@end

typedef NS_ENUM(NSUInteger, MenuHeaderState) {
    MenuHeaderState_Expand      = 0,
    MenuHeaderState_Collapse    = 1
};

@interface MenuHeaderReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *separatorView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;

@property (assign, nonatomic, getter=index, setter=setSectionIndex:) NSInteger idx;

@property (weak, nonatomic) id<MenuHeaderReusableViewDelegate> delegate;

- (void)updateState:(MenuHeaderState)state;

@end
