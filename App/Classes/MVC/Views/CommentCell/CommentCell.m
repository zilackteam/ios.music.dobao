//
//  CommentCell.m

//
//  Created by Toan Nguyen on 3/1/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)prepareForReuse{
    _avatarImageView.image = nil;
    _usernameLabel.text = nil;
    _contentLabel.text = nil;
    _dateLabel.text = nil;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
