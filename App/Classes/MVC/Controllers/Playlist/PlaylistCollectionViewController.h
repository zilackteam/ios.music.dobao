//
//  PlaylistCollectionViewController.h
//  music.application
//
//  Created by thanhvu on 3/23/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "BaseViewController.h"
#import "PlaylistEntity+CoreDataClass.h"
#import "MusicStoreManager.h"

@class PlaylistCollectionViewController;
@class MediaBaseCell;

@protocol PlaylistCollectionViewControllerDelegate <NSObject>
- (void)playlistCollectionViewController:(PlaylistCollectionViewController *)viewController didSelectedPlaylist:(PlaylistEntity *)playlist;
@end

@interface PlaylistCollectionOptionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@interface PlaylistCollectionViewController : BaseViewController

@property (weak, nonatomic) id<PlaylistCollectionViewControllerDelegate> delegate;
@property (assign, nonatomic) DataMode dataMode;

@property (weak, nonatomic, getter=selectedView, setter=setSelectedView:) id selectedView;

- (void)dissmis:(void (^ __nullable)(void))completion;

@end
