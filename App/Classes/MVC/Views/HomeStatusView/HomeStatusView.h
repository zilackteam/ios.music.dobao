//
//  HomeStatusView.h
//  music.application
//
//  Created by thanhvu on 4/2/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeStatusView;
@class Post;

@protocol HomeStatusViewDelegate <NSObject>
- (void)homeStatusView:(HomeStatusView *)homeStatusView performAction:(int)action;
@end

@interface HomeStatusView : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) id<HomeStatusViewDelegate> delegate;

- (void)updateAlpha:(float)alpha;

- (void)setPost:(Post *)post;

- (void)updateMessage:(NSString *)message;

- (void)showLoading;

- (void)hideLoading;

@end
