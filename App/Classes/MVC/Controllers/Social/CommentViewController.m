//
//  CommentViewController.m

//
//  Created by Toan Nguyen on 3/2/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "CommentViewController.h"

#import "PostMenuViewController.h"
#import "PostViewController.h"
#import "AppPostMenuController.h"

@interface CommentViewController ()<AppCommentViewDataSource>{
}

@end

@implementation CommentViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - AppCommentViewDataSource
- (AppPostMenuController *)socialPostMenuController {
    return [UIStoryboard viewController:SB_PostMenuViewController storyBoard:StoryBoardSocial];
}

- (AppPostViewController *)socialPostViewController {
    return [UIStoryboard viewController:SB_PostViewController storyBoard:StoryBoardSocial];
}

- (CGFloat)minimumHeightOfCommentCell {
    return 65.0f;
}

- (CGFloat)minimumHeightOfPostCell {
    return 125.0f;
}

- (NSString *)identifierOfPostCell {
    return @"post_cell";
}

- (NSString *)identifierOfCommentCell {
    return @"comment_cell";
}

@end
