//
//  PostCell.m

//
//  Created by Toan Nguyen on 2/29/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "PostCell.h"
#import "UIImage+Utilities.h"

@interface PostCell()
@end

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _bounderView.layer.cornerRadius = 10.0f;
    _avatarImageView.layer.cornerRadius = CGRectGetHeight(_avatarImageView.frame)/2.0;
    _avatarImageView.clipsToBounds = YES;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    _contentLabel.text = nil;
    _contentImageView.image = nil;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tapOnLikeButton:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectLikeButtonOnPostCell:)]) {
        [self.delegate didSelectLikeButtonOnPostCell:self];
    }
}

- (IBAction)tapOnEditButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectEditButtonOnPostCell:)]) {
        [self.delegate didSelectEditButtonOnPostCell:self];
    }
}

- (void)setAvatarImage:(NSString *)url {
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self performSelector:@selector(displayImage:) withObject:image afterDelay:0];
    }];
}

- (void)displayImage:(UIImage *)image {
    _avatarImageView.image = image;
}

@end
