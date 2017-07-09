//
//  SearchViewController.m

//
//  Created by thanhvu on 1/10/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "SearchViewController.h"
#import "ZLTextField.h"
#import "ApiDataProvider.h"

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    __weak IBOutlet NSLayoutConstraint *_searchTopContrain;
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet ZLTextField *_searchTextField;
    
    NSMutableArray *suggestions;
    NSArray *filters;
    
    float searchViewHeight;
}

@property (weak, nonatomic) IBOutlet UIView *searchView;

- (void)showSearchBar:(BOOL)show;

- (IBAction)onCancelSearch:(id)sender;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = RGB(68, 68, 68);
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _searchTextField.delegate = self;
    
    [ApiDataProvider fetchSuggestions:^(NSArray * _Nullable datas, BOOL success) {
        suggestions = [NSMutableArray arrayWithArray:datas];
    } refreshTimeInMinutes:24 * 60 * 30];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackground:)];
    gesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gesture];
    
    searchViewHeight = _searchView.frame.size.height;
    
    _searchTopContrain.constant = -searchViewHeight;
    [self.searchView layoutIfNeeded];
}

- (void)tapOnBackground:(UITapGestureRecognizer *)gesture {
    CGPoint touchPoint = [gesture locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:touchPoint];
    if (indexPath) {
    } else {
        [self showSearchBar:NO];
    }
}

- (void)setDefaultKeyword:(NSString *)keyword {
    dispatch_async(dispatch_get_main_queue(), ^{
        _searchTextField.text = keyword;
    });
}

/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.view];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:touchPoint];
    if (indexPath) {
        return YES;
    }
    return NO;
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showSearchBar:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self showSearchBar:NO];
}

- (void)showSearchBar:(BOOL)show {
    if (show) {
        _searchTopContrain.constant = 0;
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_searchTextField becomeFirstResponder];
        }];
    } else {
        [_searchTextField resignFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            filters = nil;
            [_tableView reloadData];
        } completion:^(BOOL finished) {
            _searchTopContrain.constant = -searchViewHeight;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self dismissViewControllerAnimated:NO completion:^{
                }];
            }];
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - table of suggestions
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (filters) {
        return [filters count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchCell"];
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    
    cell.backgroundColor = RGB(36, 36, 36);
    
    NSInteger idx = indexPath.row;
    cell.textLabel.text = filters[idx][@"name"];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = indexPath.row;
    NSString *keyword = filters[idx][@"tag"];
    
    [UIView animateWithDuration:0.2 animations:^{
        filters = nil;
        [_tableView reloadData];
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(searchViewController:searchWithKeyword:)]) {
            [_delegate searchViewController:self searchWithKeyword:keyword];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (IBAction)onCancelSearch:(id)sender {
    [self showSearchBar:NO];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(searchViewController:searchWithKeyword:)]) {
        [_delegate searchViewController:self searchWithKeyword:textField.text];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    filters = nil;
    [_tableView reloadData];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (suggestions) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (newString) {
            newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name BEGINSWITH[c] %@) OR (tag BEGINSWITH[c] %@)", newString, newString];
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:YES];
        
        filters = [[suggestions filteredArrayUsingPredicate:predicate] sortedArrayUsingDescriptors:@[descriptor]];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    return YES;
}

@end
