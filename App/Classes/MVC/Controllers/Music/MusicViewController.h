//
//  MusicViewController.h

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MenuView.h"

@interface MusicViewController : BaseViewController {
    __weak IBOutlet UICollectionView *_collectionView;
}

typedef NS_OPTIONS(NSUInteger, MusicViewType) {
    MusicViewTypeVideo        = 0,
    MusicViewTypeAlbum        = 1,
    MusicViewTypeSong         = 2,
    MusicViewTypeSingle       = 3,
};

@property (nonatomic, assign) MusicViewType viewType;

@property (nonatomic, assign) NSInteger albumId;

@end
