//
//  ShowViewController.m

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "ShowViewController.h"
#import "ShowCollectionViewCell.h"
#import "APIClient.h"
#import "AppDelegate.h"
#import "SCLAlertView.h"
#import "Session.h"
#import "LoadMoreReusableView.h"

@interface ShowViewController()<UICollectionViewDelegate, UICollectionViewDataSource> {
    UIRefreshControl *refreshControl;
    LoadMoreReusableView *footerView;
    DataPage page;
}

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) ShowList *showList;

- (void)p_fetchData;

@end

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateLocalization];
    
    _formatter = [[NSDateFormatter alloc] init];
    
    // default
    page.index = 0;
    page.numberOfPage = 20;
    
    // footer
    [_collectionView registerClass:[LoadMoreReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:@"footer"];
}

- (void)refreshControlAction {
    [refreshControl endRefreshing];
    [self p_fetchData];
}

- (void)updateLocalization {
    self.title = LocalizedString(@"tlt_show");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self p_fetchData];
}


#pragma mark - fetchdata

- (void)p_fetchData {
    if (page.state == PageStateLoading) {
        return;
    }
    
    [self showLoading:YES];
    [footerView showLoading];
    
    page.state = PageStateLoading;
    
    [[APIClient shared] getListOfShowsWithLimit:15 page:(page.index + 1) completion:^(ShowList *showList, BOOL success) {
        page.state = PageStateNone;
        if (!showList || [showList count] == 0) {
        } else {
            page.index++;
            if (!self.showList) {
                self.showList = showList;
            } else {
                [self.showList append: showList];
            }
        }
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [self showLoading:NO];
        [footerView hideLoading];
    }];
}

#pragma mark - CollectioViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_showList count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ShowCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"show_cell" forIndexPath:indexPath];
    
    Show *item = [_showList itemAtIndex:indexPath.row];
    
    [_formatter setDateFormat:APPLICATION_DATETIME_FORMAT_STRING];
    NSDate *dateTime = [_formatter dateFromString:item.time];
    
    [_formatter setDateFormat:@"dd/MM/yyyy"];
    cell.dateLabel.text = [_formatter stringFromDate:dateTime];
    
    [_formatter setDateFormat:@"HH:mm"];
    cell.timeLabel.text = [_formatter stringFromDate:dateTime];
    [cell setValue:item];
    
    if (item.status == ShowStatusPassed) {
        [cell.orderButton setTitle:LocalizedString(@"tlt_show_finished") forState:UIControlStateNormal];
    } else {
        [cell.orderButton setTitle:LocalizedString(@"tlt_show_buy_ticket") forState:UIControlStateNormal];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.bounds.size.width, 235.0f);
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

#pragma mark - ScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        [self p_fetchData];
    }
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!APPLICATION_MODE_DEMO) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        Show *item = [_showList itemAtIndex:indexPath.row];
        
        NSString *phoneNumber = [AppUtils numberString:item.contact];
        
        if ([Session shared].user && [Session shared].user.userStatus.status == AccountVIP) {
        } else {
            phoneNumber = item.secretcontact;
        }
        
        [alert addButton:phoneNumber actionBlock:^(void) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]]];
        }];
        
        id vc = [[AppDelegate sharedInstance] topViewController];
        
        [alert showInfo:vc title:item.name subTitle:item.address closeButtonTitle:LocalizedString(@"tlt_cancel") duration:0.0];
    }
}

#pragma mark - ShowViewCellDelegate
- (void)selectedPhoneNumber:(NSString *)phoneString name:(NSString *)name {
    if (!APPLICATION_MODE_DEMO) {
        NSString *phoneNumber = [AppUtils numberString:phoneString];
        
        if (phoneNumber) {
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            [alert addButton:phoneNumber actionBlock:^(void) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]]];
            }];
            
            id vc = [[AppDelegate sharedInstance] topViewController];
            
            [alert showInfo:vc title:LocalizedString(@"tlt_contact_show") subTitle:name closeButtonTitle:LocalizedString(@"tlt_cancel") duration:0.0];
        }
    }
}

@end
