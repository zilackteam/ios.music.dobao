//
//  ShowViewController.h

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef NS_OPTIONS(NSInteger, ShowState) {
    ShowStateUnknow         = 0,
    ShowStateFeature        = 1,
    ShowStatePresenting     = 2,
    ShowStatePassed         = 3
};

@interface ShowViewController : BaseViewController

@end
