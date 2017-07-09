//
//  PostCellLayout.m

//
//  Created by Toan Nguyen on 3/2/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "PostCellLayout.h"

#define CONTAINER_TOP 6
#define AVAR_TOP 8
#define AVAR_HEIGHT 45
#define AVAR_BOTTOM 16
#define CONTENT_LABEL_BOTTOM 8
#define CONTENT_IMAGE_VIEW_BOTTOM 8
#define LIKE_ICON_HEIGHT 20
#define LIKE_ICON_BOTTOM 8
#define CONTAINER_BOTTOM 6

@implementation PostCellLayout
- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentHeight = 43.0;
        _imageHeight = 10.0;
//        _othersHeight = 119.0;
        _othersHeight = CONTAINER_TOP + AVAR_TOP + AVAR_HEIGHT + AVAR_BOTTOM + CONTENT_LABEL_BOTTOM + CONTENT_IMAGE_VIEW_BOTTOM + LIKE_ICON_HEIGHT + LIKE_ICON_BOTTOM + CONTAINER_BOTTOM;
        _layoutUpdated = NO;
    }
    return self;
}

- (CGFloat) cellHeight {
    return _contentHeight + _imageHeight + _othersHeight;
}
@end
