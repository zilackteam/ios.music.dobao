//
//  UIViewController+Common.m

//
//  Created by Toan Nguyen on 1/21/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "UIViewController+Common.h"
#import "SearchDetailViewController.h"

@implementation UIViewController (Common)

#pragma mark - BarButtons
- (void)setLeftNavButton:(LeftNavButtonStyle)style {
    
    NSString *imageName;
    switch (style) {
        case None: {
            self.navigationItem.leftBarButtonItem = nil;
            return;
        }
            break;
        case Menu:
            imageName = @"ic_menu";
            break;
        case Back:
            imageName = @"ic_navigation_back";
            break;
        case Close:
            imageName = @"ic_arrow_down";
            break;
        default:
            break;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    SEL selector = (style == Menu) ? @selector(menuButtonSelected) : @selector(backButtonSelected);
    
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)showSearchButton {
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(0, 0, 30, 30);
    [searchButton setBackgroundImage:[UIImage imageNamed:@"ic_search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    self.navigationItem.rightBarButtonItem = searchBarButtonItem;
}

- (void)showShareButtonWithTarget:(id)target selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"ic_share"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = share;
}
- (void)hideSearchButton {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)showShareButton {
    NSMutableArray *barButtons = [NSMutableArray array];
    
    if (self.navigationItem.rightBarButtonItems) {
        [barButtons addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    }
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(0, 0, 30, 30);
    [shareButton setBackgroundImage:[UIImage imageNamed:@"ic_sharing_bar"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(sharingButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    [barButtons addObject:shareBarButtonItem];
    
    self.navigationItem.rightBarButtonItems = barButtons;
}
- (void)showLeftButtonWithImage:(UIImage *)img target:(id)target selector:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:img forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barItem;
}
- (void)showRightButtonWithImage:(UIImage *)img target:(id)target selector:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:img forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barItem;
}

#pragma mark - Handle events
- (void)sharingButtonSelected {
}

- (void)backButtonSelected {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)menuButtonSelected {
    [self.frostedViewController presentMenuViewController];
}

- (void)searchButtonSelected {
    SearchViewController *vc = [UIStoryboard viewController:SB_SearchViewController storyBoard:StoryBoardOther];
    vc.delegate = self;
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:vc animated:NO completion:nil];
}

#pragma mark - SearchViewControllerDelegate

- (void)searchViewController:(SearchViewController *)viewController searchWithKeyword:(NSString *)keyword {
    [viewController dismissViewControllerAnimated:NO completion:nil];
    if (![self isKindOfClass:[SearchDetailViewController class]]) {
        SearchDetailViewController *searchDetailViewController = (SearchDetailViewController *)[UIStoryboard viewController:SB_SearchDetailViewController storyBoard:StoryBoardOther];
        searchDetailViewController.keyword = keyword;
        [self.navigationController pushViewController:searchDetailViewController animated:YES];
    } else {
        [viewController setDefaultKeyword:keyword];
        
        [(SearchDetailViewController *)self fetchDataWithKeyword:keyword];
    }
}

@end
