//
//  ProgressSlider.m

//
//  Created by Toan Nguyen on 1/27/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "ProgressSlider.h"

@implementation ProgressSlider
- (CGRect)trackRectForBounds:(CGRect)bounds{
    CGFloat height = 0.2 * bounds.size.height;
    return CGRectMake(bounds.origin.x, bounds.size.height / 2 - height / 2 , bounds.size.width, height);
}

@end
