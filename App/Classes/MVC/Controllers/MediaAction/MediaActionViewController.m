//
//  MediaActionViewController.m
//  music.application
//
//  Created by thanhvu on 3/22/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "MediaActionViewController.h"

#define MEDIA_INFO_HEIGHT_OF_HEADER     60.0f
#define MEDIA_INFO_HEIGHT_OF_ITEM       50.0f
#define MAX_OF_ACTION_IN_LINE           4

@implementation MediaActionCollectionCell

@end

@implementation MediaInfoHeaderReusableView

@end

@interface MediaActionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    MediaActionList *_actionList;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;

- (void)loadActionConfiguration;

@end

@implementation MediaActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.alpha = 0;
    
    self.collectionView.layer.cornerRadius = 5.0f;
    self.collectionView.layer.borderColor = RGBA(0, 0, 0, 1).CGColor;
    self.collectionView.layer.borderWidth = 1;
    self.collectionView.backgroundColor  = RGBA(255, 255, 255, 0.9);
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 10;
    currentLayout.minimumInteritemSpacing = 10;
    
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.collectionView.allowsSelection = YES;
    [currentLayout invalidateLayout];
    
    _collectionViewHeightConstraint.constant = MEDIA_INFO_HEIGHT_OF_HEADER;
    
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view layoutIfNeeded];
    [self.collectionView layoutIfNeeded];
    
    [self loadActionConfiguration];
}

- (void)dissmis:(void(^)(void))completion {
    _collectionViewHeightConstraint.constant = MEDIA_INFO_HEIGHT_OF_HEADER;// 10 for extend
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)loadActionConfiguration {
    // init menu list
    if (_configurationPlistFile) {
        NSArray *actionData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_configurationPlistFile ofType:@"plist"]];
        _actionList = [MediaActionList parseObject:actionData];
        
        [_collectionView performBatchUpdates:^{
            [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished) {
        }];
    }
    
    int numberOfLines =  ceil(MAX((int)_actionList.count, MAX_OF_ACTION_IN_LINE) / MAX_OF_ACTION_IN_LINE);
    
    _collectionViewHeightConstraint.constant = (numberOfLines + 1) * MEDIA_INFO_HEIGHT_OF_ITEM + 5 + MEDIA_INFO_HEIGHT_OF_HEADER + 80;
    
    [UIView animateWithDuration:0.5 delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.alpha = 1.0;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                     }];
}

- (void)setActionsConfigureFile:(NSString *)configurationPlistFile {
    _configurationPlistFile = configurationPlistFile;
    
    [self loadActionConfiguration];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dissmis:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        if (!_actionList) {
            return 0;
        }
        return _actionList.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MediaActionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    MediaActionObject *action = [_actionList itemAtIndex:indexPath.item];
    
    if (action.type == MediaActionAddFavourite && _highlightFavourite) {
        cell.imageView.image = [UIImage imageNamed:action.iconHighlight];
    } else {
        cell.imageView.image = [UIImage imageNamed:action.icon];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 0) {
            MediaInfoHeaderReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
            
            if (_mediaTitle) {
                headerView.titleLabel.text = _mediaTitle;
            }
            
            headerView.titleLabel.numberOfLines = 2;
            headerView.titleLabel.textColor = RGB(96, 96, 96);
            headerView.backgroundColor = [UIColor clearColor];
            
            reusableview = headerView;
        }
    } else {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        
        footerView.backgroundColor = RGB(96, 96, 96);
        reusableview = footerView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(collectionView.bounds.size.width, MEDIA_INFO_HEIGHT_OF_HEADER);
    } else {
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(collectionView.bounds.size.width, 1.0f);
    } else {
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int numberOfColumns = MIN((int)_actionList.count, MAX_OF_ACTION_IN_LINE);
    
    CGFloat width = (_collectionView.bounds.size.width - (numberOfColumns + 1) * 10) / numberOfColumns;
    
    return CGSizeMake(width - 1, MEDIA_INFO_HEIGHT_OF_ITEM);
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MediaActionObject *actionObject = [_actionList itemAtIndex:indexPath.item];
        
        if (_delegate && [_delegate respondsToSelector:@selector(mediaActionViewController:actionWithView:performAction:)]) {
            [_delegate mediaActionViewController:self actionWithView:_mediaView performAction:actionObject.type];
        }
    }
}

@end
