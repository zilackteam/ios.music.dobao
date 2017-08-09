//
//  PostViewController.m

//
//  Created by Toan Nguyen on 3/28/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "PostViewController.h"

@interface PostViewController ()<AppPostViewDataSource>

@end

@implementation PostViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - AppPostViewDataSource
- (void)postViewController:(AppPostViewController *)controller postButton:(ZLRoundButton *)roundButton {
    roundButton.borderWidth = 1.0f;
    roundButton.borderColor = APPLICATION_COLOR_TEXT;
    roundButton.cornerRadius = 3.0f;
    roundButton.fillColor = [UIColor clearColor];
    [roundButton.titleLabel setFont:[UIFont fontWithName:APPLICATION_FONT size:16.0]];
    
    [roundButton setFrame:CGRectMake(0, 0, 50, 30)];
    [roundButton setTitle:LocalizedString(@"tlt_public_post") forState:UIControlStateNormal];
}
@end
