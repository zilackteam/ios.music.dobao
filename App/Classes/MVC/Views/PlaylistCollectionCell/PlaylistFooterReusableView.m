//
//  PlaylistFooterReusableView.m
//  music.application
//
//  Created by thanhvu on 3/30/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "PlaylistFooterReusableView.h"
@interface PlaylistFooterReusableView()
@property (strong, nonatomic) IBOutlet UICollectionReusableView *view;

@end
@implementation PlaylistFooterReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
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

@end
