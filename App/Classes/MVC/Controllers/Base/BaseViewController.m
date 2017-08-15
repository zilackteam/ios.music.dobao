//
//  BaseViewController.m
//  music.thuphuong
//
//  Created by thanhvu on 8/14/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "BaseViewController.h"
#import "TitleView.h"

@interface BaseViewController ()
@property (nonatomic, strong) TitleView *titleView;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleView = (TitleView *)[AppUtils loadFromNibNamed:@"TitleView"];
    _titleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44);
    _titleView.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.titleView = _titleView;
}

- (void)setTitle:(NSString *)title {
    [_titleView setTitle:title];
}

- (void)setTitleIconNamed:(NSString *)iconName {
    [_titleView setIcon:[UIImage imageNamed:iconName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
