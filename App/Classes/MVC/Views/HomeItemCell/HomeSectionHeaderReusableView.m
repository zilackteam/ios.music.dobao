//
//  HomeSectionReusableView.m
//  music.application
//
//  Created by thanhvu on 3/18/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeSectionHeaderReusableView.h"
@interface HomeSectionHeaderReusableView()

@property (nonatomic, weak) IBOutlet UILabel* detailLabel;

@end

@implementation HomeSectionHeaderReusableView

- (void)p_initDefault {
    _detailLabel.userInteractionEnabled = YES;
    [_detailLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail:)]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self p_initDefault];
}

+ (UINib *) nib {
    UINib *_nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    return _nib;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_initDefault];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_initDefault];
    }
    return self;
}

- (void)showDetail:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sectionBaseView:didSelectedDetailSection:)]) {
        [self.delegate sectionBaseView:self didSelectedDetailSection:self.section];
    }
}

@end
