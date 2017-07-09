//
//  HomeSectionFooterReusableView.m
//  music.application
//
//  Created by thanhvu on 3/19/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeSectionFooterReusableView.h"
@interface HomeSectionFooterReusableView()
{
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;
@property (assign, nonatomic) HomeSectionFooterState state;

@end

@implementation HomeSectionFooterReusableView
@synthesize delegate = _delegate;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (UINib *) nib {
    UINib *_nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    return _nib;
}

- (void)initDefault {
    _activityView.hidesWhenStopped = YES;
    [self updateState:HomeSectionFooterState_None];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initDefault];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initDefault];
    }
    return self;
}

- (IBAction)touchExtend:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(footerView:section:performAction:)]) {
        if (_state != HomeSectionFooterState_None && _state != HomeSectionFooterState_Loading) {
            //[_delegate footerView:self section:[self section] performAction:HomeSectionFooterAction_Extend];
            
            [(id<HomeSectionFotterReusableViewDelegate>)_delegate footerView:self section:[self section] performAction:HomeSectionFooterAction_Extend];
        }
    }
}

- (void)setState:(HomeSectionFooterState)state {
    _state = state;
    [self updateState:_state];
}

- (HomeSectionFooterState)getState {
    return _state;
}

- (void)updateState:(HomeSectionFooterState)state {
    _state = state;
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case HomeSectionFooterState_None:
            {
                _expandButton.alpha = 0;
                [_activityView stopAnimating];
            }
            case HomeSectionFooterState_Loading:
            {
                _expandButton.alpha = 0;
                [_activityView startAnimating];
            }
                break;
            case HomeSectionFooterState_Extend:
            {
                [_expandButton setImage:[UIImage imageNamed:@"ic_narrow"] forState:UIControlStateNormal];
                [_activityView stopAnimating];
                _expandButton.alpha = 1;
            }
                break;
            case HomeSectionFooterState_Narrow:
            {
                [_expandButton setImage:[UIImage imageNamed:@"ic_expand"] forState:UIControlStateNormal];
                [_activityView stopAnimating];
                _expandButton.alpha = 1;
            }
                break;
            default:
                break;
        }
    });
}

@end
