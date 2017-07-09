//
//  SongPlayingCell.h

//
//  Created by Toan Nguyen on 2/19/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongPlayingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *playingIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@end
