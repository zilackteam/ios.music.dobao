//
//  UIViewController+Common.h

//
//  Created by Toan Nguyen on 1/21/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "SearchViewController.h"

typedef NS_OPTIONS(NSInteger, LeftNavButtonStyle) {
    None,
    Menu,
    Back,
    Close,
    Share
};

@interface UIViewController (Common)<SearchViewControllerDelegate>

- (void)setLeftNavButton:(LeftNavButtonStyle)style;
- (void)showSearchButton;
- (void)hideSearchButton;
- (void)showShareButton;

- (void)showShareButtonWithTarget:(id)target selector:(SEL)selector;
- (void)backButtonSelected;
- (void)sharingButtonSelected;
- (void)showLeftButtonWithImage:(UIImage *)img target:(id)target selector:(SEL)selector;
- (void)showRightButtonWithImage:(UIImage *)img target:(id)target selector:(SEL)selector;
@end
