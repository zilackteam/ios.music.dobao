//
//  LoadMoreReusableView.m
//  music.application
//
//  Created by thanhvu on 4/14/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "LoadMoreReusableView.h"

@interface LoadMoreReusableView()
@property (strong, nonatomic) IBOutlet UICollectionReusableView *view;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation LoadMoreReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializeSubviews];
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
    
    [_activityView setHidesWhenStopped:YES];
    _activityView.color = APPLICATION_COLOR_TEXT;
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

- (void)showLoading {
    //    _statusContainerView.alpha = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activityView startAnimating];
    });
}

- (void)hideLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activityView stopAnimating];
    });
}

@end
