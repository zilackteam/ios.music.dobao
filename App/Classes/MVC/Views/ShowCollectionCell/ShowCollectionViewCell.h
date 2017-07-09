//
//  ShowCollectionViewCell.h
//  music.application
//
//  Created by thanhvu on 3/31/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "CollectionBaseCell.h"
#import "BaseObject.h"

@interface ShowCollectionViewCell : CollectionBaseCell

// properties
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;

// setvalue
- (void)setValue:(id<BaseObject>)show;

@end
