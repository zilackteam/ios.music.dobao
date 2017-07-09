//
//  PostMenuViewController.m
//  Singer-Thuphuong
//
//  Created by thanhvu on 9/1/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "PostMenuViewController.h"
#import "Post.h"

@interface PostMenuViewController ()
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end

@implementation PostMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _backgroundView.alpha = 0;
    _backgroundView.layer.cornerRadius = 5.0f;
    
    [_deleteButton setTitle:LocalizedString(@"tlt_post_delete") forState:UIControlStateNormal];
    [_editButton setTitle:LocalizedString(@"tlt_post_edit") forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 1;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}

- (IBAction)editPost:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(postViewController:editPost:)]) {
        [_delegate postViewController:self editPost:_post];
    }
}

- (IBAction)deletePost:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(postViewController:deletePost:)]) {
        [_delegate postViewController:self deletePost:_post];
    }
}

@end
