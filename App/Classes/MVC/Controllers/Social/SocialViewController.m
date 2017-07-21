//
//  SocialViewController.m

//
//  Created by Toan Nguyen on 1/22/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "SocialViewController.h"
#import "PostList.h"
#import "Post.h"
#import "PostCell.h"
#import "PostCellLayout.h"
#import "APIClient.h"
#import "Session.h"
#import "CommentViewController.h"
#import "PostViewController.h"
#import "PostMenuViewController.h"
#import "NSDate+TimeDif.h"
#import "AppDelegate.h"
#import "UIImage+Utilities.h"

@interface SocialViewController ()<UITableViewDataSource, UITableViewDelegate,PostCellDelegate,PostViewControllerDelegate, PostMenuViewDelegate, CommentViewDelegate>{
    NSMutableArray *_layouts;
    
    PostList *_postList;
    
    DataPage page;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)p_fetchData;
- (void)p_deletePost:(Post *)aPost;
@end

@implementation SocialViewController
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[Auth shared] addObserver:self selector:@selector(updateUI) forEvent:AuthEventUserSessionChanged];
    
    self.title = LocalizedString(@"tlt_social_network");
    [self updateUI];
    [self.tableView setBackgroundColor:RGB(244, 244, 244)];
    
    // default
    page.index = 0;
    page.numberOfPage = 5;
    page.state = PageStateNone;
    
    _layouts = [NSMutableArray array];
    
    [self p_fetchData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)updateUI {
    if ([[Session shared] signedIn] && [Session shared].user.level == UserLevelMaster) {
        UIButton *composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        composeButton.frame = CGRectMake(0, 0, 30, 40);
        [composeButton setImage:[UIImage imageNamed:@"ic_social_compose"] forState:UIControlStateNormal];
        [composeButton addTarget:self action:@selector(composeButtonSelected: ) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:composeButton];
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    _layouts = [NSMutableArray array];
}

- (void)onCreatePost {
}

- (void)composeButtonSelected:(id)sender {
    if ([Session shared].user.level == UserLevelMaster) {
        PostViewController *postVc = (PostViewController *)[UIStoryboard viewController:SB_PostViewController storyBoard:StoryBoardSocial];
        postVc.mode = PostViewModeAdd;
        postVc.delegate = self;
        UIViewController *vc = [[UINavigationController alloc] initWithRootViewController:postVc];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
}

- (void)p_fetchData {
    if (page.state == PageStateLoading) {
        return;
    }
    
    page.state = PageStateLoading;
    [self showLoading:YES];
    
    [[APIClient shared] getListPostsWithLimit:page.numberOfPage page:(page.index + 1) completion:^(PostList *postList) {
        if (postList && [postList count] > 0) {
            page.index += 1;
            
            if (!_postList) {
                _postList = postList;
            } else {
                [_postList append:postList];
            }
            
            for (Post *aPost in postList.items) {
                [_layouts addObject:[aPost layout]];
            }
            
            [_tableView reloadData];
        }
        page.state = PageStateNone;
        [self showLoading:NO];
    }];
}

- (void)p_deletePost:(Post *)aPost {
    NSInteger idx = [_postList indexOfObject:aPost];
    if (idx != NSNotFound) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_postList removeObjectAtIndex:idx];
            [_layouts removeObjectAtIndex:idx];
            
            [_tableView beginUpdates];
            [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation: UITableViewRowAnimationMiddle];
            [_tableView endUpdates];
        });
    }
}

- (void)configCell:(PostCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.index = indexPath.row;
    NSInteger idx = cell.index;
    Post *aPost = [_postList itemAtIndex:idx];
    //config layout
    PostCellLayout *layout = _layouts[idx];
    cell.textHeight.constant = layout.contentHeight;
    cell.imageHeight.constant = layout.imageHeight;
    cell.contentLabel.text = aPost.content;
    cell.singerNameLabel.text = aPost.user.fullName ? aPost.user.fullName : aPost.user.secName;
    cell.postDateLabel.text = [NSDate datefromString:aPost.date format:APPLICATION_DATETIME_FORMAT_STRING].stringDifferenceSinceNow;
    [cell setAvatarImage:aPost.user.avatarUrl];
    [cell.likeIconImageView setImage:[UIImage imageNamed:aPost.isLiked ? @"ic_header_like" : @"ic_header_unlike"]];
    cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", aPost.likeCount];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%ld", aPost.commentCount];
    if (layout.layoutUpdated) {
        if (aPost.imageUrl) {
            [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:aPost.imageUrl]];
        }
    } else {
        if (aPost.imageUrl) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:aPost.imageUrl] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        layout.layoutUpdated = YES;
                        if (image) {
                            CGFloat width = [UIScreen mainScreen].bounds.size.width - 16;
                            layout.imageHeight = width * image.size.height / image.size.width;
                        }
                        if (idx == cell.index) {
                            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        }
                    }
                });
            }];
        }
    }
    
    [cell setNeedsUpdateConstraints];
/*
    BOOL lastItemReached = (aPost == [_postList.items lastObject]);
    if (lastItemReached)
    {
        [self p_fetchData];
    }
*/
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [_layouts[indexPath.row] cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _layouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    [self configCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentViewController *vc = (CommentViewController *)[UIStoryboard viewController:SB_CommentViewControler storyBoard:StoryBoardSocial];
    vc.post = [_postList itemAtIndex:indexPath.row];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - PostViewControllerDelegate
- (void)postViewController:(PostViewController *)controller updateCompletedWithPost:(Post *)aPost {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if (aPost) {
        if (controller.mode == PostViewModeAdd) {
            [_postList.items insertObject:aPost atIndex:0];
            [_layouts insertObject:[aPost layout] atIndex:0];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        } else {
            NSInteger idx = [_postList indexOfObject:aPost];
            if (idx != NSNotFound) {
                [_layouts replaceObjectAtIndex:idx withObject:[aPost layout]];
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

- (void)postViewController:(PostViewController *)controller deleteCompletedWithPost:(Post *)aPost {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [self p_deletePost:aPost];
}

#pragma mark - PostCellDelegate

- (void)didSelectLikeButtonOnPostCell:(PostCell *)cell{
    if ([[Session shared] signedIn]) {
        NSInteger index = cell.index;
        Post *aPost = [_postList itemAtIndex:index];
        [[APIClient shared] updateLikeStatus:!aPost.isLiked ofPostId:aPost.identifier completion:^(BOOL isLiked, NSInteger likesCount, NSError *error) {
            if (error == nil) {
                aPost.isLiked = isLiked;
                aPost.likeCount = likesCount;
                if (cell.index == index) {
                    [cell.likeIconImageView setImage:[UIImage imageNamed:aPost.isLiked ? @"ic_header_like" : @"ic_header_unlike"]];
                    cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", aPost.likeCount];
                }
            }
        }];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:LocalizedString(@"msg_error_feature_login_require")
                                   delegate:nil
                          cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
    }
}

- (void)didSelectEditButtonOnPostCell:(PostCell *)cell {
    if ([[Session shared] signedIn] && ([[Session shared] user].level == UserLevelMaster)) {
        NSIndexPath *path = [_tableView indexPathForCell:cell];
        
        PostMenuViewController *vc = [UIStoryboard viewController:SB_PostMenuViewController storyBoard:StoryBoardSocial];
        vc.delegate = self;
        vc.post = [_postList.items objectAtIndex:path.row];
        [self.navigationController presentViewController:vc animated:NO completion:^{
        }];
    }
}

#pragma mark - ScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
     float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
     if (bottomEdge >= scrollView.contentSize.height) {
         [self p_fetchData];
     }
}

#pragma mark - CommentView Delegate
- (void)commentViewController:(CommentViewController *)controller deletePost:(Post *)post {
    [controller.navigationController popViewControllerAnimated:YES];
    [self p_deletePost:post];
}

#pragma mark - PostMenuView Delegate
- (void)postViewController:(PostMenuViewController *)postMenuViewController editPost:(id)post {
    [postMenuViewController dismissViewControllerAnimated:NO completion:^{
        PostViewController *postVc = (PostViewController *)[UIStoryboard viewController:SB_PostViewController storyBoard:StoryBoardSocial];
        postVc.mode = PostViewModeEditing;
        postVc.post = post;
        postVc.delegate = self;
        UIViewController *vc = [[UINavigationController alloc] initWithRootViewController:postVc];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }];
}

- (void)postViewController:(PostMenuViewController *)vc deletePost:(Post *)post {
    [vc dismissViewControllerAnimated:NO completion:^{
        [AppActions showLoading];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[APIClient shared] deletePost:post.identifier completion:^(BOOL success) {
                [AppActions hideLoading];
                if (success) {
                    [self p_deletePost:post];
                }
            }];
        });
    }];
}

@end
