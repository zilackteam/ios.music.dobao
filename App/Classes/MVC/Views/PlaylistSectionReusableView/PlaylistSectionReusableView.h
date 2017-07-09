//
//  PlaylistSectionReusableView.h
//  music.application
//
//  Created by thanhvu on 3/20/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SectionReusableBaseView.h"
#import "BaseObject.h"

@class PlaylistSectionReusableView;
@protocol PlaylistSectionReusableViewDelegate <SectionReusableBaseViewDelegate>

@optional
- (void)playlistSectionResableView:(PlaylistSectionReusableView *)view selectedObject:(id<BaseObject>) object;

@end

@interface PlaylistSectionReusableView : SectionReusableBaseView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *detailView;

//@property (assign, nonatomic) id<PlaylistSectionReusableViewDelegate> delegate;

+ (UINib *) nib;

- (void)setValue:(id<BaseObject>)object;

@end
