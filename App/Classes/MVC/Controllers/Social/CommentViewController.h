//
//  CommentViewController.h

//
//  Created by Toan Nguyen on 3/2/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Post.h"

@class CommentViewController;

@protocol CommentViewDelegate <NSObject>
- (void)commentViewController:(CommentViewController *)controller deletePost:(Post *)post;
@end

@interface CommentViewController : BaseViewController

@property (nonatomic, assign) id<CommentViewDelegate> delegate;
@property (nonatomic, strong) Post *post;

@end
