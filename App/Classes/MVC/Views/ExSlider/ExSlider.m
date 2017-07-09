//
//  ExSlider.m
//  Singer-Thuphuong
//
//  Created by thanhvu on 10/16/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "ExSlider.h"

@implementation ExSlider

#define THUMB_SIZE 10
#define EFFECTIVE_THUMB_SIZE 10
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -EFFECTIVE_THUMB_SIZE, -EFFECTIVE_THUMB_SIZE);
    return CGRectContainsPoint(bounds, point);
}

- (BOOL) beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event {
/*
    CGRect bounds = self.bounds;
    float thumbPercent = (self.value - self.minimumValue) / (self.maximumValue - self.minimumValue);
    float thumbPos = THUMB_SIZE + (thumbPercent * (bounds.size.width - (2 * THUMB_SIZE)));
    CGPoint touchPoint = [touch locationInView:self];
    return (touchPoint.x >= (thumbPos - EFFECTIVE_THUMB_SIZE) &&
            touchPoint.x <= (thumbPos + EFFECTIVE_THUMB_SIZE));
*/
    return YES;
}

@end
