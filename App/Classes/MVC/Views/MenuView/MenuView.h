//
//  MenuView.h

//
//  Created by thanhvu on 12/3/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, MenuViewType) {
    MenuViewType_Song,
    MenuViewType_Playlist,
    MenuViewType_SongDownloading,
    MenuViewType_Album,
    MenuViewType_Video
};

@class MenuView;
@protocol MenuViewDelegate <NSObject>

@optional

- (void)menuView:(MenuView *)view willSelectedType:(MenuViewType)type;
- (void)menuView:(MenuView *)view didSelectedType:(MenuViewType)type;

@end

@interface MenuView : UIView
{
}

@property (nonatomic, assign) id<MenuViewDelegate> delegate;

@property (nonatomic, assign, setter=setTouchDisable:) BOOL untouched;

+ (id)menuWithTypes:(MenuViewType)types,...;

- (void)setTypes:(MenuViewType)firstType, ... NS_REQUIRES_NIL_TERMINATION;

- (void)setSelectedType:(MenuViewType)type;

@end

@interface MenuButton : UIButton
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) MenuViewType type;
@end
