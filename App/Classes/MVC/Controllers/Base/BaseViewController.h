//
//  BaseViewController.h

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//
#import "ZLBaseViewController.h"
#import "UIViewController+Common.h"
#import "SCLAlertView.h"
#import "AppActions.h"
#import "Auth.h"

@interface BaseViewController : ZLBaseViewController
//convenience
@property (assign, nonatomic) CGSize screenSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (readonly, nonatomic) CGFloat bottomHeight;

- (void)updateBottomLayout;

- (void)updateLocalization;

- (void)useMainBackground;

- (void)useMainBackgroundOpacity:(float)opacity;

- (void)showLoading:(BOOL)loading;

@end
