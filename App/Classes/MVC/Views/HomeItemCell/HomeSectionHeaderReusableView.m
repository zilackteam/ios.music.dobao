//
//  HomeSectionReusableView.m
//  music.application
//
//  Created by thanhvu on 3/18/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeSectionHeaderReusableView.h"
@interface HomeSectionHeaderReusableView()

@end

@implementation HomeSectionHeaderReusableView

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
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

@end
