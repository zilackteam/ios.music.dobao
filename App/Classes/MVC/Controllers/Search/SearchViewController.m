//
//  SearchViewController.m

//
//  Created by thanhvu on 1/10/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<AppSearchUISetting> {
}

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma AppSearchUISetting
- (void)AppSearchUITableView:(UITableView *)tableView inputTextField:(ZLTextField *)inputField {
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorColor = RGB(68, 68, 68);
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
@end
