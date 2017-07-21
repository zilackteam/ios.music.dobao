//
//  CommentViewController.m

//
//  Created by Toan Nguyen on 3/2/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentList.h"
#import "Comment.h"
#import "PostCellLayout.h"
#import "PostCell.h"
#import "CommentCell.h"
#import "APIClient.h"
#import <PHFComposeBarView.h>
#import "Session.h"
#import "NSDate+TimeDif.h"
#import "PostMenuViewController.h"
#import "PostViewController.h"
#import "UIStoryboard+Extension.h"
#import "UIImage+Utilities.h"

@interface CommentCellLayout: NSObject
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGFloat otherHeight;
@end

@implementation CommentCellLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _contentHeight = 16.0f;
        _otherHeight = 85.0 - 16.0f;
    }
    return self;
}

- (CGFloat)cellHeight {
    return _contentHeight + _otherHeight;
}
@end


@interface CommentViewController ()<UITableViewDataSource, UITableViewDelegate, PHFComposeBarViewDelegate, PostCellDelegate, PostMenuViewDelegate, PostViewControllerDelegate>{
    CommentList *_commentList;
    PostCellLayout *_postCellLayout;
    NSMutableArray *_commentLayouts;
}
@property (weak, nonatomic) IBOutlet PHFComposeBarView *composeView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CommentViewController
- (void)dealloc
{
    [self unregisterForKeyboardNotifications];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setups];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    if (_post) {
        [[APIClient shared] getListCommentsOfPost:_post.identifier withCompletion:^(CommentList *list) {
            _commentList = list;
            _commentLayouts = [NSMutableArray array];
            CGFloat width = [UIScreen mainScreen].bounds.size.width - 8.0 * 3.0 - 35.0;
            UIFont *textFont = [UIFont fontWithName:APPLICATION_FONT size:12.5];
            for (int i = 0; i < [list count]; i++) {
                CommentCellLayout *layout = [CommentCellLayout new];
                Comment *cmt = [list itemAtIndex:i];
                CGRect bounds = [cmt.content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : textFont} context:nil];
                layout.contentHeight = bounds.size.height;
                [_commentLayouts addObject:layout];
            }
            
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self adjustConstraintWithInfo:notification.userInfo isShown:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self adjustConstraintWithInfo:notification.userInfo isShown:NO];
}

- (void)adjustConstraintWithInfo:(NSDictionary *)info isShown:(BOOL)show {
    UIViewAnimationCurve curve = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat height = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    NSString *identifier = show ? @"keyboard_show" : @"keyboard_height";
    
    [UIView beginAnimations:identifier context:nil];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    self.bottomConstraint.constant = show ? height : self.bottomHeight;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (IBAction)tapBackground:(UITapGestureRecognizer *)sender {
    [_composeView.textView resignFirstResponder];
}

- (void) setups {
    self.title = LocalizedString(@"tlt_comment");
    [self registerForKeyboardNotifications];
    [self setLeftNavButton:Back];
    [self hideSearchButton];
    [_composeView setMaxCharCount:160];
    [_composeView setMaxLinesCount:5];
    [_composeView setPlaceholder:[NSString stringWithFormat:@"%@...", LocalizedString(@"tlt_comment")]];
    [_composeView setDelegate:self];
    [_composeView.button setImage:[UIImage imageNamed:@"ic_send_cmt"] forState:UIControlStateNormal];
    [_composeView.button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    _composeView.buttonTitle = nil;
    
    if (_post == nil) {
        return;
    }
    _postCellLayout = [PostCellLayout new];
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 32;
    UIFont *textFont = [UIFont fontWithName:APPLICATION_FONT size:14];
    CGRect bounds = [AppUtils boundingRectForString:_post.content font:textFont width:width];
    _postCellLayout.contentHeight = bounds.size.height;
    if (_post.imageUrl) {
        NSURL *imageUrl = [NSURL URLWithString:_post.imageUrl];
        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:imageUrl];
        UIImage *img = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:key];
        if (img) {
            _postCellLayout.imageHeight = width * img.size.height / img.size.width;
            _postCellLayout.layoutUpdated = YES;
        }
    } else {
        _postCellLayout.layoutUpdated = YES;
        _postCellLayout.imageHeight = 0;
    }
    
    if ([[Session shared] signedIn] && [Session shared].user.level == UserLevelMaster) {
        UIButton *composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        composeButton.frame = CGRectMake(0, 0, 30, 40);
        [composeButton setImage:[UIImage imageNamed:@"ic_w_post_edit"] forState:UIControlStateNormal];
        [composeButton addTarget:self action:@selector(onEditPost:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:composeButton];
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)onEditPost:(id)sender {
    PostMenuViewController *vc = [UIStoryboard viewController:SB_PostMenuViewController storyBoard:StoryBoardSocial];
    vc.delegate = self;
    vc.post = _post;
    [self.navigationController presentViewController:vc animated:NO completion:^{
    }];
}

- (void)configPostCell:(PostCell *)cell{
    //config layout
    cell.textHeight.constant = _postCellLayout.contentHeight;
    cell.imageHeight.constant = _postCellLayout.imageHeight;
    cell.contentLabel.text = _post.content;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 32;
    
    CGRect bounds = [AppUtils boundingRectForString:cell.contentLabel.text font:cell.contentLabel.font width:width];
    cell.textHeight.constant = bounds.size.height;
    
    [cell.likeIconImageView setImage:[UIImage imageNamed:_post.isLiked ? @"ic_header_like" : @"ic_header_unlike"]];
    cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", _post.likeCount];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%ld", _post.commentCount];
    cell.singerNameLabel.text = _post.user.fullName ? _post.user.fullName : _post.user.secName;
    cell.postDateLabel.text = [[NSDate datefromString:_post.date format:APPLICATION_DATETIME_FORMAT_STRING] stringDifferenceSinceNow];
    
    [cell setAvatarImage:_post.user.avatarUrl];
    
    if (_postCellLayout.layoutUpdated) {
        if (_post.imageUrl) {
            [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:_post.imageUrl]];
        }
    } else {
        if (_post.imageUrl) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:_post.imageUrl] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        _postCellLayout.layoutUpdated = YES;
                        if (image) {
                            CGFloat width = [UIScreen mainScreen].bounds.size.width - 32;
                            _postCellLayout.imageHeight = width * image.size.height / image.size.width;
                        }
                        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    }
                });
            }];
        }
    }
    
    [cell setNeedsUpdateConstraints];
}

- (void)configCommentCell:(CommentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Comment *aComment = [_commentList itemAtIndex:indexPath.row];
    CommentCellLayout *layout = _commentLayouts[indexPath.row];
    cell.contentHeightConstraint.constant = layout.contentHeight;
    cell.contentLabel.text = aComment.content;
    if (aComment.user) {
        cell.usernameLabel.text = (aComment.user.fullName != nil) ? aComment.user.fullName : aComment.user.secName;
//        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:aComment.user.avatarUrl]];
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:aComment.user.avatarUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.avatarImageView.image = [UIImage roundedImage:image cornerRadius:image.size.height/2];
        }];
    }
    cell.dateLabel.text = [[NSDate datefromString:aComment.date format:APPLICATION_DATETIME_FORMAT_STRING] stringDifferenceSinceNow];
    [cell setNeedsUpdateConstraints];
}

#pragma mark - PHFComposeBarViewDelegate
- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    if ([[Session shared] signedIn]) {
        if (_post && composeBarView.text) {
            [self showLoading:YES];
            
            NSData *data = [composeBarView.text dataUsingEncoding:NSNonLossyASCIIStringEncoding];
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            [[APIClient shared] commentPostWithId:_post.identifier content:text completion:^(Comment *aComment) {
                if (aComment != nil && _commentList != nil) {
                    aComment.user = [Session shared].user;
                    [_commentList.items insertObject:aComment atIndex:0];
                    CommentCellLayout *layout = [CommentCellLayout new];
                    CGFloat width = [UIScreen mainScreen].bounds.size.width - 8.0 * 3.0 - 35.0;
                    UIFont *textFont = [UIFont fontWithName:APPLICATION_FONT size:12.5];
                    CGRect bounds = [aComment.content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : textFont} context:nil];
                    layout.contentHeight = bounds.size.height;
                    [_commentLayouts insertObject:layout atIndex:0];
                    _post.commentCount += 1;
                    [_tableView beginUpdates];
                    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView endUpdates];
                }
                [self showLoading:NO];
            }];
        }
        [_composeView setText:nil];
        [_composeView.textView resignFirstResponder];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"msg_error_feature_login_require") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [_postCellLayout cellHeight];
    }
    
    return [_commentLayouts[indexPath.row] cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _post == nil ?  0 : 1;
    }
    return _commentList == nil ? 0 : _commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *identifier = @"post_cell";
        PostCell *cell = (PostCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.delegate = self;
        [self configPostCell:cell];
        return cell;
    }else{
        static NSString *identifier = @"comment_cell";
        CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        [self configCommentCell:cell atIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - PostCellDelegate
- (void)didSelectLikeButtonOnPostCell:(PostCell *)cell{
    if ([[Session shared] signedIn]) {
        if (_post) {
            [[APIClient shared] updateLikeStatus:!_post.isLiked ofPostId:_post.identifier completion:^(BOOL isLiked, NSInteger likesCount, NSError *error) {
                if (error == nil) {
                    _post.isLiked = isLiked;
                    _post.likeCount = likesCount;
                    [cell.likeIconImageView setImage:[UIImage imageNamed:_post.isLiked ? @"ic_header_like" : @"ic_header_unlike"]];
                    cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", _post.likeCount];
                }
            }];
        }
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"msg_error_feature_login_require") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
    }
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [AppActions showLoading];
            [[APIClient shared] deletePost:post.identifier completion:^(BOOL success) {
                [AppActions hideLoading];
                if (success) {
                    if (_delegate && [_delegate respondsToSelector:@selector(commentViewController:deletePost:)]) {
                        [_delegate commentViewController:self deletePost:_post];
                    }
                }
            }];
        });
        
    }];
}

#pragma mark - PostViewControllerDelegate
- (void)postViewController:(PostViewController *)controller updateCompletedWithPost:(Post *)aPost {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    _post = aPost;
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
}
@end
