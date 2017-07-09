//
//  PostMenuViewController.h
//  Singer-Thuphuong
//
//  Created by thanhvu on 9/1/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostMenuViewController;
@class Post;

@protocol PostMenuViewDelegate <NSObject>

@optional
- (void)postViewController:(PostMenuViewController *)vc deletePost:(id)post;
- (void)postViewController:(PostMenuViewController *)vc editPost:(id)post;

@end

@interface PostMenuViewController : UIViewController

@property (assign, nonatomic) Post *post;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) id<PostMenuViewDelegate> delegate;

@end
