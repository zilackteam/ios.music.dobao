//
//  SectionReusableBaseView.h
//  music.application
//
//  Created by thanhvu on 3/19/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaAccessoryView.h"

@class SectionReusableBaseView;

@protocol SectionReusableBaseViewDelegate <NSObject>

@optional
- (void)sectionBaseView:(SectionReusableBaseView *)view didSelectedSection: (NSInteger)section;
- (void)sectionBaseView:(SectionReusableBaseView *)view didSelectedAccessoryView: (MediaAccessoryView *)accessoryView atSection:(NSInteger)section;
- (void)sectionBaseView:(SectionReusableBaseView *)view didSelectedDetailSection:(NSInteger)section;

@end

@interface SectionReusableBaseView : UICollectionReusableView

@property (strong, nonatomic) IBOutlet UICollectionReusableView *view;
@property (assign, nonatomic, getter=section, setter=setSection:) NSInteger sec;
@property (weak, nonatomic) IBOutlet MediaAccessoryView *accessoryView;

@property (weak, nonatomic) id<SectionReusableBaseViewDelegate> delegate;

+ (UINib *) nib;
@end
