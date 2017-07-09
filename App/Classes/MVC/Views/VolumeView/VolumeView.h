//
//  VolumeView.h

//
//  Created by Toan Nguyen on 1/27/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface VolumeView : UIControl
@property (nonatomic, assign) IBInspectable NSUInteger maxValue;
@property (nonatomic, assign) IBInspectable NSUInteger currentValue;
@property (nonatomic, strong) IBInspectable UIColor *tintColor;
@property (nonatomic, strong) IBInspectable UIColor *defaultColor;
@property (nonatomic, assign) IBInspectable CGFloat dotRadius;
@end
