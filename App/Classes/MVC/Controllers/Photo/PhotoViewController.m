//
//  PhotoViewController.m

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoCollectionCell.h"
#import "RACollectionViewReorderableTripletLayout.h"
#import "APIClient.h"
#import "Photo.h"
#import "PhotoPreviewViewController.h"
#import "LoadMoreReusableView.h"

@interface PhotoViewController() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    DataPage page;
    LoadMoreReusableView *footerView;
}

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (strong, nonatomic) PhotoList *photoList;

- (void)p_fetchData;

@end

@implementation PhotoViewController

static NSString *kCellIdentifier = @"PhotoCollectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self useMainBackgroundOpacity:0.05];
    
    _photoCollectionView.backgroundColor = [UIColor clearColor];
    self.title = LocalizedString(@"tlt_photo");
    
    // footer
    [_photoCollectionView registerClass:[LoadMoreReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:@"footer"];
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_photoCollectionView.collectionViewLayout;
    currentLayout.footerReferenceSize = CGSizeMake(_photoCollectionView.frame.size.width, 80.0f);
    
    [currentLayout invalidateLayout];
    // default
    page.index = 0;
    page.numberOfPage = 20;
    
    [self p_fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)p_fetchData {
    if (page.state == PageStateLoading) {
        return;
    }
    
    [self showLoading:YES];
    [footerView showLoading];
    
    page.state = PageStateLoading;
    [[APIClient shared] getListOfPhotosWithLimit:30 page:(page.index + 1) completion:^(PhotoList *list, BOOL success) {
        page.state = PageStateNone;
        if (!list || [list count] == 0) {
        } else {
            page.index++;
            if (!self.photoList) {
                self.photoList = list;
            } else {
                [self.photoList append: list];
            }
        }
        
        [UIView transitionWithView:_photoCollectionView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [_photoCollectionView reloadData];
        } completion:nil];
        
        [self showLoading:NO];
        [footerView hideLoading];
    }];
}

- (void)refreshControlAction {
    [self p_fetchData];
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_photoList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:0.4];
    Photo *aPhoto = [_photoList itemAtIndex:indexPath.item];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:aPhoto.thumbUrl]];

    return cell;
}

- (CGFloat)reorderingItemAlpha:(UICollectionView *)collectionview
{
    return .3f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoPreviewViewController *vc = (PhotoPreviewViewController *)[UIStoryboard viewController:SB_PhotoPreviewViewController storyBoard:StoryBoardOther];
    vc.photoList = _photoList;
    vc.startIndex = indexPath.row;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:true completion:nil];
}

- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(50.f, 0, 50.f, 0); //Sorry, horizontal scroll is not supported now.
}

- (UIEdgeInsets)autoScrollTrigerPadding:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(64.f, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section{
    return RACollectionViewTripletLayoutStyleSquare; //same as default !
}
- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView{
    return UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
}
- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView{
    return 5.0;
}
- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView{
    return 5.0;
}
- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView{
    return 5.0;
}
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    Photo *aPhoto = [_photoList itemAtIndex:fromIndexPath.item];
    [_photoList removeObjectAtIndex:fromIndexPath.item];
    [_photoList insertObject:aPhoto atIndex:toIndexPath.item];
}
- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - ScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        [self p_fetchData];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
    } else if (kind == UICollectionElementKindSectionFooter) {
        footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        reusableview = footerView;
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 80);
}
@end
