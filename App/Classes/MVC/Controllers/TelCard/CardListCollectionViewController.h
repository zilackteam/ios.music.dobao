//
//  CardListCollectionViewController.h
//  music.application
//
//  Created by thanhvu on 4/26/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CardlistCollectionOptionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@interface CardListCollectionViewController : BaseViewController

- (void)dissmis:(void (^ __nullable)(void))completion;

@end
