//
//  PostCell.m

//
//  Created by Toan Nguyen on 2/29/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "PostCell.h"
@implementation PostCell

- (void)bounderView:(UIView *)bounderView userImageView:(UIImageView *)imageView {
    bounderView.layer.cornerRadius = 10.0f;
    imageView.layer.cornerRadius = CGRectGetHeight(imageView.frame)/2.0;
    imageView.clipsToBounds = YES;
}

@end
