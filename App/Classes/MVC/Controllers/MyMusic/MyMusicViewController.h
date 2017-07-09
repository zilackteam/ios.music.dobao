//
//  MyMusicViewController.h

//
//  Created by thanhvu on 12/13/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "BaseViewController.h"
#import "MusicStoreManager.h"
#import "MenuView.h"

typedef NS_OPTIONS(NSInteger, MyMusicMode) {
    MyMusicMode_Offline,
    MyMusicMode_Online
};

@interface MyMusicViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet MenuView *menuView;

@property (nonatomic, assign) MyMusicMode mode;
@end
