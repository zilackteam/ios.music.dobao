//
//  PostCellLayout.h

//
//  Created by Toan Nguyen on 3/2/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostCellLayout : NSObject
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) CGFloat othersHeight;
@property (nonatomic, assign) BOOL layoutUpdated;

- (CGFloat) cellHeight;
@end
