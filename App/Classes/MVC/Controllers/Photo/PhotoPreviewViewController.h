//
//  PhotoPreviewViewController.h

//
//  Created by Toan Nguyen on 2/25/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PhotoList.h"

@interface PhotoPreviewViewController : BaseViewController
@property (nonatomic, weak) PhotoList *photoList;
@property (nonatomic, assign) NSInteger startIndex;
@end
