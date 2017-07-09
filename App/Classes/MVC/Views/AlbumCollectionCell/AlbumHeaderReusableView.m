//
//  AlbumHeaderReusableView.m
//  music.application
//
//  Created by thanhvu on 3/28/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "AlbumHeaderReusableView.h"
@interface AlbumHeaderReusableView()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UICollectionReusableView *view;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
@implementation AlbumHeaderReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
    [self setNeedsLayout];
    [self layoutIfNeeded];
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

- (void)setTitle:(NSString *)title detail:(NSString *)detail description:(NSString *)description imageUrl:(NSString *)imageUrl {
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                  placeholderImage:[UIImage imageNamed:@"placeholder_mini"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                      if (image) {
                          [UIView transitionWithView:_imageView
                                            duration:0.5
                                             options:UIViewAnimationOptionTransitionCrossDissolve
                                          animations:^{
                                              _imageView.image = image;
                                          } completion:nil];
                      }
                  }];
    
    _detailLabel.text = detail;
    _nameLabel.text = title;
    _descriptionLabel.text = description;
}

@end
