//
//  MenuView.m

//
//  Created by thanhvu on 12/3/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "MenuView.h"

@implementation MenuButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    MenuButton *button = [super buttonWithType:buttonType];
    {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setTitleColor:RGBA(136, 136, 136, 1) forState:UIControlStateNormal];
        
        button.backgroundColor = [UIColor clearColor];
        [button.titleLabel setFont:[UIFont fontWithName:APPLICATION_FONT size:16]];
    }
    return button;
}
@end

@interface MenuView() {
    MenuButton *selectedButton;
    float paddingLeft_;
    float paddingRight_;
    float buttonWidth_;
}

@property (nonatomic, assign) MenuViewType selectedType;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, nonnull, strong) NSMutableArray *buttonArrays;


- (NSString *)p_titleWithType:(MenuViewType)type;

- (void)p_setSelectedMenuButton:(MenuButton *)button;

@end

@implementation MenuView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    _indicatorView = [[UIView alloc] init];
    _indicatorView.backgroundColor = RGB(240, 216, 106);
    
    paddingLeft_ = 10.0f;
    paddingRight_ = 10.0f;
    
    [self addSubview:_indicatorView];
}

+ (id)menuWithTypes:(MenuViewType)firstType, ... {
    MenuView *menuView = [MenuView new];
    
    [menuView setTypes:firstType, nil];
    
    return menuView;
}

- (NSString *)p_titleWithType:(MenuViewType)type {
    switch (type) {
        case MenuViewType_Song:
        return LocalizedString(@"tlt_songs");
        break;
        case MenuViewType_Playlist:
        return LocalizedString(@"tlt_playlist");
        break;
        case MenuViewType_SongDownloading:
        return LocalizedString(@"tlt_downloading");
        break;
        case MenuViewType_Album:
        return LocalizedString(@"tlt_album");
        break;
        case MenuViewType_Video:
        return LocalizedString(@"tlt_video");
        break;
        default:
        return nil;
        break;
    }
}

- (void)p_setSelectedMenuButton:(MenuButton *)button {
    if (selectedButton) {
        selectedButton.selected = NO;
    }
    
    selectedButton = button;
    selectedButton.selected = YES;
    
    _selectedType = button.type;
    
    NSInteger _selectedIndex = button.index;
    
    if (_delegate && [_delegate respondsToSelector:@selector(menuView:willSelectedType:)]) {
        [_delegate menuView:self willSelectedType:_selectedType];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = _indicatorView.frame;
        f.origin.x = buttonWidth_ * _selectedIndex + paddingLeft_;
        _indicatorView.frame = f;
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(menuView:didSelectedType:)]) {
            [_delegate menuView:self didSelectedType:_selectedType];
        }
    }];
}

- (void)setTypes:(MenuViewType)firstType, ... {
    NSMutableArray *_typesArray = [NSMutableArray array];
    MenuViewType type;
    va_list argumentList;
    
    [_typesArray addObject:@(firstType)];
    
    va_start(argumentList, firstType);
    while ((type = va_arg(argumentList, MenuViewType))) {
        [_typesArray addObject:@(type)];
    }
    
    va_end(argumentList);
    
    NSInteger count = [_typesArray count];
    
    buttonWidth_ = (CGRectGetWidth(self.frame) - paddingLeft_ - paddingRight_)/count;
    float buttonHeight_ = self.frame.size.height - 2;
    
    _indicatorView.frame = CGRectMake(paddingLeft_, buttonHeight_, buttonWidth_, 2);
    
    _buttonArrays = [NSMutableArray array];
    
    for (int i = 0; i < count; i++) {
        MenuViewType type = [[_typesArray objectAtIndex:i] intValue];
        
        MenuButton *button = [MenuButton buttonWithType:UIButtonTypeCustom];
        // set properties
        button.index = i;
        button.type = type;
        // title
        [button setTitle:[self p_titleWithType:type] forState:UIControlStateNormal];
        // frame
        button.frame = CGRectMake(i * buttonWidth_ + paddingLeft_, 0, buttonWidth_, buttonHeight_);
        
        [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelected:)]];
        [self addSubview:button];
        
        [_buttonArrays addObject:button];
    }
}

- (void)setSelectedType:(MenuViewType)type {
    for (MenuButton *button in _buttonArrays) {
        if (button.type == type) {
            [self p_setSelectedMenuButton:button];
            break;
        }
    }
}

- (void)onSelected:(UITapGestureRecognizer *)gesture {
    if (_untouched) {
        return;
    }
    UIView *view = gesture.view;
    if ([view isKindOfClass:[MenuButton class]] && view != selectedButton) {
        [self p_setSelectedMenuButton:(MenuButton *)view];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
