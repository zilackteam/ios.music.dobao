//
//  HomeItemCell.m
//  music.application
//
//  Created by thanhvu on 3/17/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeItemCell.h"

@interface HomeItemCell()<AppHomeItemProtocol>

@end

@implementation HomeItemCell

- (UIImage *)placeHolder {
    return [UIImage imageNamed:@"placeholder_video"];
}

@end
