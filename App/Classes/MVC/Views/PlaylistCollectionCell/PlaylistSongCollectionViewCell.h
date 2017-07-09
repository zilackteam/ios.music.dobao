//
//  PlaylistSongCollectionViewCell.h
//  music.application
//
//  Created by thanhvu on 3/20/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaBaseCell.h"

@interface PlaylistSongCollectionViewCell : MediaBaseCell
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

- (void)setItemNo:(NSInteger)no;
- (void)setPlayingState:(BOOL)playing;

@end
