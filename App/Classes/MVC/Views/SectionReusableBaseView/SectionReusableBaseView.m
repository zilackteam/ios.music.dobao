//
//  SectionReusableBaseView.m
//  music.application
//
//  Created by thanhvu on 3/19/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "SectionReusableBaseView.h"

@interface SectionReusableBaseView()
@end

@implementation SectionReusableBaseView
@synthesize sec = _sec;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (UINib *) nib {
    UINib *_nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    return _nib;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializeSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeSubviews];
    }
    return self;
}

- (void)initializeSubviews {
    NSString *className = NSStringFromClass([self class]);
    
    [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    
    [self addSubview:self.view];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeTop]];
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeLeft]];
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeBottom]];
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeRight]];
    
    if (_accessoryView != nil) {
        _accessoryView.userInteractionEnabled = YES;
        [_accessoryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOnAccessory:)]];
    }
}

- (void)touchOnAccessory:(UITapGestureRecognizer *)gesture {
    if (_delegate && [_delegate respondsToSelector:@selector(sectionBaseView:didSelectedAccessoryView:atSection:)]) {
        
        if ([gesture.view isKindOfClass:[MediaAccessoryView class]]) {
            MediaAccessoryView *view = (MediaAccessoryView *)gesture.view;
            if (view.enable) {
                [_delegate sectionBaseView:self didSelectedAccessoryView:view atSection:_sec];
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (_delegate && [_delegate respondsToSelector:@selector(sectionBaseView:didSelectedSection:)]) {
        [_delegate sectionBaseView:self didSelectedSection:_sec];
    }
}

- (NSLayoutConstraint *)pin:(id)item attribute:(NSLayoutAttribute)attribute {
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:item
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

- (NSInteger)section {
    return _sec;
}

- (void)setSection:(NSInteger)section {
    _sec = section;
}

@end

