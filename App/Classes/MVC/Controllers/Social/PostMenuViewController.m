//
//  PostMenuViewController.m
//  music.application
//
//  Created by thanhvu on 9/1/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "PostMenuViewController.h"

@interface PostMenuViewController ()<AppPostMenuViewProtocol>
@end

@implementation PostMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)postMenuView:(AppPostMenuController *)vc backgroundView:(UIView *)backgroundView {
    backgroundView.layer.cornerRadius = 5.0f;
}

@end
