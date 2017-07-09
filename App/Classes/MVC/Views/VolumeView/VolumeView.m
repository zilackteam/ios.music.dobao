//
//  VolumeView.m

//
//  Created by Toan Nguyen on 1/27/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "VolumeView.h"

@implementation VolumeView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setups];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setups];
    }
    return self;
}

- (void)setups {
//    self.backgroundColor = [UIColor clearColor];
    self.dotRadius = 3.0;
    self.tintColor = [UIColor redColor];
    self.defaultColor = [UIColor whiteColor];
    self.maxValue = 10;
    self.currentValue = 0;
}

- (void)setMaxValue:(NSUInteger)maxValue{
    _maxValue = maxValue;
    [self setNeedsDisplay];
}

- (void)setCurrentValue:(NSUInteger)currentValue {
    _currentValue = MAX(0, currentValue);
    [self setNeedsDisplay];
}

- (void)setDotRadius:(CGFloat)dotRadius{
    _dotRadius = dotRadius;
    [self setNeedsDisplay];
}

- (void)setDefaultColor:(UIColor *)defaultColor {
    _defaultColor = defaultColor;
    [self setNeedsDisplay];
}

- (void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (_maxValue < 1) {
        return;
    }
    CGSize size = self.bounds.size;
    CGFloat minAlpha = 0.0;
    CGFloat stepAlpha = (1.0 - minAlpha) / _maxValue;
    CGFloat stepY = (size.height - 2 * _dotRadius) / _maxValue;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (int i = 0; i <= _currentValue; ++i) {
        CGContextSetFillColorWithColor(ctx, [_tintColor colorWithAlphaComponent:minAlpha + i * stepAlpha].CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(size.width/2 - _dotRadius, size.height - 2 * _dotRadius - i * stepY, 2 * _dotRadius, 2 * _dotRadius));
    }
    
    for (NSInteger i = _currentValue + 1; i <= _maxValue; ++i) {
        CGContextSetFillColorWithColor(ctx, [_defaultColor colorWithAlphaComponent:minAlpha + i * stepAlpha].CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(size.width/2 - _dotRadius, size.height - 2 * _dotRadius - i * stepY, 2 * _dotRadius, 2 * _dotRadius));
    }
}

- (void)updateValueWithTouchPosition:(CGPoint)point {
    CGFloat step = (_maxValue < 1) ? 0 : self.bounds.size.height / _maxValue;
    NSInteger idx = _maxValue - MIN(MAX((NSInteger)(point.y/step + 0.5), 0), _maxValue);
    self.currentValue = idx;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self updateValueWithTouchPosition:[touch locationInView:self]];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self updateValueWithTouchPosition:[touch locationInView:self]];
    return YES;
}


@end
