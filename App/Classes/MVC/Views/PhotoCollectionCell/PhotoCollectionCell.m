//
//  PhotoCollectionCell.m

//
//  Created by thanhvu on 12/3/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "PhotoCollectionCell.h"

@implementation PhotoCollectionCell

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        _imageView.alpha = .7f;
    }else {
        _imageView.alpha = 1.f;
    }
}
@end
