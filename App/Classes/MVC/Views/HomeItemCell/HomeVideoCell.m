//
//  HomeVideoCell.m
//  music.application
//
//  Created by thanhvu on 3/19/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeVideoCell.h"

@interface HomeVideoCell()<AppHomeItemProtocol>

@end

@implementation HomeVideoCell

- (UIImage *)placeHolder {
    return [UIImage imageNamed:@"placeholder_video"];
}
@end
