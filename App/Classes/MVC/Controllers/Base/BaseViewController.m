//
//  BaseViewController.m

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "BaseViewController.h"
#import "AppActions.h"
#import "APIClient.h"

@interface BaseViewController()<UIGestureRecognizerDelegate>
//@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DLog(@"::::::::::----> %@", NSStringFromClass([self class]));
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackground:)];
    gesture.cancelsTouchesInView = NO;
    gesture.delegate = self;
    
    [self.view addGestureRecognizer:gesture];
    self.screenSize = [UIScreen mainScreen].bounds.size;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self showSearchButton];
    [self setLeftNavButton:Menu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLocalization)
                                                 name:kLanguageChangedNotification object:nil];
/*
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, CGRectGetWidth(self.view.frame) - 100, 44)];
    _titleLabel.backgroundColor = [UIColor clearColor];
//    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = APPLICATION_COLOR_TEXT;
    _titleLabel.font = [UIFont fontWithName:APPLICATION_FONT size:16];
*/
    self.view.backgroundColor = APPLICATION_COLOR;
//    self.navigationItem.titleView = _titleLabel;
}

- (void)setTitle:(NSString *)title {
/*
    if (_titleLabel) {
        _titleLabel.text = title;
    }
*/
    self.navigationItem.title = title;
}

- (CGFloat)bottomHeight {
    return [AudioPlayer shared].allItems.count == 0 ? 0 : APPLICATION_MINI_PLAYER_HEIGHT;
}

- (void)tapOnBackground:(id)sender{
    [self hideKeyboard];
}

- (void)updateLocalization {
}

- (void)useMainBackground {
    self.view.backgroundColor = APPLICATION_COLOR;
    
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_main_background_bl"]];
        _backgroundImageView.alpha = 0.5;//defautl
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        [self.view insertSubview:_backgroundImageView atIndex:0];
    }
}

- (void)useMainBackgroundOpacity:(float)opacity {
    [self useMainBackground];
    if (_backgroundImageView) {
        _backgroundImageView.alpha = opacity;
    }
}

- (void)showLoading:(BOOL)loading {
    if (loading) {
        [AppActions showLoading];
    } else {
        [AppActions hideLoading];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateBottomLayout];
/*
    NSArray *leftBars = self.navigationItem.leftBarButtonItems;
    NSArray *rightBars = self.navigationItem.rightBarButtonItems;
    
    float w = CGRectGetWidth(self.view.frame);
    
    NSUInteger cLeft = 0;
    NSUInteger cRight = 0;
    float spc = 50.0f;
    
    if (leftBars && [leftBars count] > 0) {
        cLeft = [leftBars count];
        
        w -= spc * cLeft;
    }
    
    if (rightBars && [rightBars count] > 0) {
        cRight = [rightBars count];
        
        w -= spc * cRight;
    }
    
    _titleLabel.frame = CGRectMake(cLeft * spc, 0, w, 44);
*/
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideKeyboard];
//    [[APIClient shared] cancelAllRequest];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    [self.frostedViewController panGestureRecognized:sender];
}

- (void)updateBottomLayout {
    if (_bottomConstraint) {
        _bottomConstraint.constant = self.bottomHeight;
        [self.view layoutIfNeeded];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    return YES;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
