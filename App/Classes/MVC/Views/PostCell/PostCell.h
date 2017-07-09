//
//  PostCell.h

//
//  Created by Toan Nguyen on 2/29/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostCell;

@protocol PostCellDelegate <NSObject>
@optional
- (void)didSelectLikeButtonOnPostCell:(PostCell *)cell;
- (void)didSelectEditButtonOnPostCell:(PostCell *)cell;
@end

@interface PostCell : UITableViewCell
@property (nonatomic, assign) NSInteger index;
@property(nonatomic, weak) id<PostCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *singerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likeIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *commentIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
//@property (weak, nonatomic) IBOutlet UIButton *editingButton;
@property (weak, nonatomic) IBOutlet UIView *bounderView;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;

- (void)setAvatarImage:(NSString *)url;
@end
