//
//  SocialCollectionViewController.m
//  music.application
//
//  Created by thanhvu on 4/18/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "SocialCollectionViewController.h"
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
#import "PostCollectionCell.h"
#import "Auth.h"

@interface SocialCollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, PostViewControllerDelegate> {
    PostList *_postList;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation SocialCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[Auth shared] addObserver:self selector:@selector(updateUI) forEvent:AuthEventUserSessionChanged];
    
    self.title = LocalizedString(@"tlt_social_network");
    [self.collectionView setBackgroundColor:RGB(244, 244, 244)];
    
    [self p_fetchData];
}

- (void)p_fetchData {
    [self showLoading:YES];
    [[APIClient shared] getListPostsWithCompletion:^(PostList *postList) {
        _postList = postList;
        [_collectionView reloadData];
        [self showLoading:NO];
    }];
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

- (void)configCell:(PostCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = indexPath.item;
    Post *post = [_postList itemAtIndex:idx];
    cell.contentLabel.text = post.content;
    cell.nameLabel.text = post.user.fullName ? post.user.fullName : post.user.secName;
    cell.postDateLabel.text = [NSDate datefromString:post.date format:APPLICATION_DATETIME_FORMAT_STRING].stringDifferenceSinceNow;
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:post.user.avatarUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.avatarView.image = [UIImage roundedImage:image cornerRadius:image.size.height/2];
    }];
    
    [cell.iconLikeView setImage:[UIImage imageNamed:post.isLiked ? @"ic_header_like" : @"ic_header_unlike"]];
    cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", post.likeCount];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%ld", post.commentCount];
    if (post.imageUrl) {
        [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:post.imageUrl]];
    }
    [cell setNeedsUpdateConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDatasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_postList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [self configCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {
    return NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.bounds.size.width - 16;
    
    return CGSizeMake(width, 320);
}

#pragma mark - PostViewControllerDelegate
- (void)postViewController:(PostViewController *)controller updateCompletedWithPost:(Post *)aPost {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if (aPost) {
        if (controller.mode == PostViewModeAdd) {
            [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
        } else {
            NSInteger idx = [_postList.items indexOfObject:aPost];
            if (idx != NSNotFound) {
                [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
            }
        }
    }
}

- (void)postViewController:(PostViewController *)controller deleteCompletedWithPost:(Post *)aPost {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [_postList.items removeObject:aPost];
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

@end
