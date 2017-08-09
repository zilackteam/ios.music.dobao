//
//  SocialViewController.m

//
//  Created by Toan Nguyen on 1/22/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "SocialViewController.h"

@interface SocialViewController ()<AppSocialViewProtocol>{
}

@end

@implementation SocialViewController

#pragma mark - AppSocialViewProtocol
- (void)socialView:(AppSocialViewController *)viewController tableView:(UITableView *)tableView {
    [tableView setBackgroundColor:RGB(244, 244, 244)];
}

- (NSString *)identifierOfPostCell {
    return @"cell";
}

- (CGFloat)minimumHeightOfCell {
    return 130.0f;
}

- (AppCommentViewController *)socialCommentViewController {
    return [UIStoryboard viewController:SB_CommentViewControler storyBoard:StoryBoardSocial];
}

- (AppPostMenuController *)socialPostMenuController {
    return [UIStoryboard viewController:SB_PostMenuViewController storyBoard:StoryBoardSocial];
}

- (AppPostViewController *)socialPostViewController {
    return [UIStoryboard viewController:SB_PostViewController storyBoard:StoryBoardSocial];
}

#pragma mark - UIView
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

@end
