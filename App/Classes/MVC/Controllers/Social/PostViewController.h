//
//  PostViewController.h

//
//  Created by Toan Nguyen on 3/28/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@class PostViewController;

typedef NS_ENUM(NSInteger, PostViewMode) {
    PostViewModeAdd,
    PostViewModeEditing
};

@protocol PostViewControllerDelegate <NSObject>
@optional
- (void)postViewController:(PostViewController *)controller updateCompletedWithPost:(Post *)aPost;
- (void)postViewController:(PostViewController *)controller deleteCompletedWithPost:(Post *)aPost;
@end

@interface PostViewController : UIViewController
@property (nonatomic, assign) PostViewMode mode;
@property (nonatomic, assign) Post *post;
@property (nonatomic, weak) id<PostViewControllerDelegate> delegate;
@end
