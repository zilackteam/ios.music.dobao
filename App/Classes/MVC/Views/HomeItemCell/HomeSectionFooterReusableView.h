//
//  HomeSectionFooterReusableView.h
//  music.application
//
//  Created by thanhvu on 3/19/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "SectionReusableBaseView.h"
@class HomeSectionFooterReusableView;

typedef NS_ENUM(NSUInteger, HomeSectionFooterAction){
    HomeSectionFooterAction_Extend = 0,
    HomeSectionFooterAction_Narrow = 1
};

typedef NS_ENUM(NSUInteger, HomeSectionFooterState) {
    HomeSectionFooterState_None,
    HomeSectionFooterState_Loading,
    HomeSectionFooterState_Extend,
    HomeSectionFooterState_Narrow
};

@protocol HomeSectionFotterReusableViewDelegate <SectionReusableBaseViewDelegate>

@optional
- (void)footerView:(HomeSectionFooterReusableView *)view section:(NSInteger)section performAction:(HomeSectionFooterAction)action;

@end

@interface HomeSectionFooterReusableView : SectionReusableBaseView
//@property(nonatomic, weak) id<HomeSectionFotterReusableViewDelegate> delegate;

- (HomeSectionFooterState)getState;
- (void)updateState:(HomeSectionFooterState)state;
// override delegate

@end
