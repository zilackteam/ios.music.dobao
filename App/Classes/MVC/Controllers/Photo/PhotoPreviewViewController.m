//
//  PhotoPreviewViewController.m

//
//  Created by Toan Nguyen on 2/25/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "PhotoPreviewViewController.h"
#import "Photo.h"
#import "PhotoZoomCell.h"
#import "AppDelegate.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
@interface PhotoPreviewViewController ()<UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLeftNavButton:Back];
    self.navigationItem.rightBarButtonItem = nil;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    [layout setItemSize:CGSizeMake(self.screenSize.width, self.screenSize.height - [UINavigationBar appearance].bounds.size.height)];
    [_collectionView reloadData];
    [self.view layoutIfNeeded];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_startIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)backButtonSelected {
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_photoList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    PhotoZoomCell *cell = (PhotoZoomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    Photo *aPhoto = [_photoList itemAtIndex:indexPath.item];
    [cell setImageUrl:aPhoto.url];
    return cell;
}



@end
