//
//  ShowCollectionViewCell.m
//  music.application
//
//  Created by thanhvu on 3/31/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "ShowCollectionViewCell.h"
#import "Show.h"

@interface ShowCollectionViewCell()

@end

@implementation ShowCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
    {
    }
    return self;
}

- (void)setValue:(id<BaseObject>)obj {
    if ([obj isKindOfClass:[Show class]]) {
        Show *show = (Show *)obj;
        _nameLabel.text = show.name;
        _addressLabel.text = show.address?show.address:@"";
    }
}

@end
