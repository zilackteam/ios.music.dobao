//
//  HomeSectionReusableView.h
//  music.application
//
//  Created by thanhvu on 3/18/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionReusableBaseView.h"

@protocol HomeSectionHeaderReusableViewDelegate <NSObject>
@end

@interface HomeSectionHeaderReusableView : SectionReusableBaseView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

+ (UINib *) nib;

@end
