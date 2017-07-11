//
//  MenuCollectionViewController.m
//  music.application
//
//  Created by thanhvu on 3/21/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "MenuCollectionViewController.h"
#import "AccountManagerController.h"
#import "MenuHeaderReusableView.h"
#import "MenuCollectionCell.h"
#import "MenuAccountView.h"
#import "Session.h"
#import "APIClient.h"
#import "MusicViewController.h"
#import "MyMusicViewController.h"
#import "Auth.h"
#import "UIImage+Utilities.h"

#pragma mark - MenuSection
@implementation MenuSection
+ (id)parseObject:(id)obj {
    if (obj && [NSNull null] != obj && [obj isKindOfClass:[NSDictionary class]]) {
        
        MenuSection *section = [MenuSection new];
        
        id tmp = [obj valueForKey:@"name"];
        if (tmp && [NSNull null] != tmp) {
            section.name = tmp;
        }
        
        section.items = [NSMutableArray array];
        
        tmp = [obj valueForKey:@"items"];
        if (tmp && [NSNull null] != tmp && [tmp isKindOfClass:[NSArray class]]) {
            for (int i = 0; i < [tmp count]; i++) {
                MenuObject *menuObject = [MenuObject parseObject:[tmp objectAtIndex:i]];
                if (menuObject) {
                    [section.items addObject:menuObject];
                }
            }
        }
        
        return section;
    }
    return nil;
}

- (NSInteger)numberOfItems {
    if (!_items) {
        return 0;
    }
    return [_items count];
}

- (MenuObject *)itemAtIndex:(NSInteger)index {
    if (index > [self numberOfItems] - 1) {
        return nil;
    } else {
        return [_items objectAtIndex:index];
    }
}
@end

#pragma mark - MenuObject
@implementation MenuObject

+ (id)parseObject:(id)obj {
    if (!obj || [NSNull null] == obj) {
        return nil;
    }
    
    MenuObject *menu = [MenuObject new];
    
    menu.name = [obj stringValueKey:@"name"];
    menu.icon = [obj stringValueKey:@"icon"];
    menu.identifier = [obj stringValueKey:@"s_identifier"];
    menu.optionValue = [obj stringValueKey:@"value"];
    menu.enableDirection = [obj boolValueKey:@"direction"];
    menu.storyBoard = [obj stringValueKey:@"sb"];
    
    return menu;
}

@end

@implementation MenuSectionList

+ (id)parseObject:(id)obj {
    if (obj && [NSNull null] != obj && [obj isKindOfClass:[NSArray class]]) {
        
        MenuSectionList *sectionlist = [MenuSectionList new];
        sectionlist.items = [NSMutableArray array];
        
        for (int i = 0; i < [obj count]; i++) {
            id tmp = [obj objectAtIndex:i];
            
            MenuSection *section = [MenuSection parseObject:tmp];
            if (section != nil) {
                [sectionlist.items addObject:section];
            }
        }
        
        return sectionlist;
    }
    return nil;
}

@end

#pragma mark - MenuCollectionViewController Implementation
@interface MenuCollectionViewController ()<MenuHeaderReusableViewDelegate, MenuCollectionCellDelegate> {
    UIImageView *avatarView;
}
@property (nonatomic, strong) MenuSectionList *sectionList;

- (void)p_fetchData;

@end

@implementation MenuCollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLocalization)
                                                 name:kLanguageChangedNotification object:nil];
    
    self.collectionView.backgroundColor  = [UIColor whiteColor];
    float headerHeight = 0.0f;
    self.collectionView.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
    self.collectionView.allowsSelection = YES;
    
    avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_avatar_none_bar"]];
    {
        avatarView.contentMode = UIViewContentModeScaleAspectFit;
        avatarView.userInteractionEnabled = YES;
        avatarView.layer.cornerRadius = avatarView.frame.size.height/2.0;
        avatarView.layer.borderWidth = 1.0f;
        avatarView.layer.borderColor = RGB(255, 255, 255).CGColor;
        [avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarButtonSelected:)]];
    }
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:avatarView];
    
    [[Auth shared] addObserver:self selector:@selector(userLoginChangedState) forEvent:AuthEventUserSessionChanged];
    [[Auth shared] addObserver:self selector:@selector(userLoginChangedState) forEvent:AuthEventLoginSuccess];
    
    self.navigationItem.leftBarButtonItem = barButton;
    
    [self p_fetchData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self userLoginChangedState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)userLoginChangedState {
    if ([[Session shared] signedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            User *user = [[Session shared] user];
            self.navigationItem.title = user.name;
            UIImageView *logoutView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_account_logout_bar"]];
            logoutView.userInteractionEnabled = YES;
            [logoutView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logout:)]];
            UIBarButtonItem *logoutBarButton = [[UIBarButtonItem alloc] initWithCustomView:logoutView];
            self.navigationItem.rightBarButtonItem = logoutBarButton;
            
            [avatarView sd_setImageWithURL:[NSURL URLWithString:[Session shared].user.avatarUrl] placeholderImage:[UIImage imageNamed:@"ic_account_photo_holder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    avatarView.image = [UIImage roundedImage:image cornerRadius:image.size.height/2];
                }
            }];
        });
    } else {
        avatarView.image = [UIImage imageNamed:@"ic_avatar_none_bar"];
        self.navigationItem.title = @"";
        self.navigationItem.rightBarButtonItem = nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateLocalization {
    [self.collectionView reloadData];
}

#pragma mark - Fetch Data
- (void)p_fetchData {
    // init menu list
    NSDictionary *menuDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"main_menu" ofType:@"plist"]];
    _sectionList = [MenuSectionList parseObject:[menuDict valueForKey:@"items"]];
}

#pragma mark - Login
- (void)avatarButtonSelected:(UITapGestureRecognizer *)gesture {
    id viewController = [UIStoryboard viewController:SB_Nav_AccountManagerController storyBoard:StoryBoardAccount];
    
    [self.frostedViewController hideMenuViewController];
    self.frostedViewController.contentViewController = viewController;
}

#pragma mark - Logout
- (void)logout:(UITapGestureRecognizer *)gesture {
    [[Auth shared] logout];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (!_sectionList) {
        return 0;
    }
    return _sectionList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    MenuSection *menuSection = [_sectionList itemAtIndex:section];
    
    if (menuSection.collape) {
        return 0;
    }
    return menuSection.numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MenuCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    MenuSection *section = [_sectionList itemAtIndex:indexPath.section];
    
    MenuObject *item = [section itemAtIndex:indexPath.item];
    
    NSAssert(item != nil, @"Menu Item can't be nil");

    cell.iconView.image = [UIImage imageNamed:item.icon];
    cell.nameLabel.text = LocalizedString(item.name);
    cell.nameLabel.font = [UIFont fontWithName:APPLICATION_FONT size:16];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        MenuHeaderReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        headerView.delegate = self;
        
        MenuSection *section = [_sectionList itemAtIndex:indexPath.section];
        
        headerView.titleLabel.text = LocalizedString(section.name);
        if (indexPath.section == 0) {
            headerView.separatorView.alpha = 0;
        } else {
            headerView.separatorView.alpha = 1;
        }
        [headerView setSectionIndex:indexPath.section];
        [headerView updateState:section.collape?MenuHeaderState_Collapse:MenuHeaderState_Expand];
        reusableview = headerView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 90.);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.bounds.size.width;
    return CGSizeMake(width, 50.0f);
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark <MenuHeaderReusableViewDelegate>
- (void)menuHeaderResableView:(MenuHeaderReusableView *)headerReusableView selectedSection:(NSInteger)index {
    MenuSection *section = [_sectionList itemAtIndex:index];
    section.collape = !section.collape;
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:index]];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark <MenuCollectionCellDelegate>
- (void)didSelectedMenuCollectionCell:(MenuCollectionCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    MenuSection *section = [_sectionList itemAtIndex:indexPath.section];
    MenuObject *menuObject = [section itemAtIndex:indexPath.row];
    
    if (!menuObject.identifier || [menuObject.identifier isEqualToString:@""]) {
        return;
    }
    
    if ([menuObject.identifier isEqualToString:SB_LiveStreamingViewController])
    {
        id vc = nil;
        if ([[Session shared] signedIn] && [Session shared].user.level == UserLevelMaster)
        {
            vc = [UIStoryboard viewController:SB_LiveBroadCastingViewController storyBoard:menuObject.storyBoard];
        }
        else
        {
            vc = [UIStoryboard viewController:SB_LivePlayingViewController storyBoard:menuObject.storyBoard];
        }
        [self presentViewController:vc animated:YES completion:^{
        }];
    } else {
        UIViewController *vc = [UIStoryboard viewController:menuObject.identifier storyBoard:menuObject.storyBoard];
        
        if (vc == nil) {
            return;
        }
        
        if ([menuObject.identifier isEqualToString:SB_MusicViewController]) {
            NSString *value = menuObject.optionValue;
            if ([value isEqualToString:@"video"]) {
                [(MusicViewController *)vc setViewType:MusicViewTypeVideo];
            } else if ([value isEqualToString:@"song"]) {
                [(MusicViewController *)vc setViewType:MusicViewTypeSong];
            } else if ([value isEqualToString:@"album"]) {
                [(MusicViewController *)vc setViewType:MusicViewTypeAlbum];
            } else if ([value isEqualToString:@"single"]) {
                [(MusicViewController *)vc setViewType:MusicViewTypeSingle];
            }
        } else if ([menuObject.identifier isEqualToString:SB_MyMusicViewController]) {
            NSString *value = menuObject.optionValue;
            if ([value isEqualToString:@"offline"]) {
                [(MyMusicViewController *)vc setMode:MyMusicMode_Offline];
            } else {
                [(MyMusicViewController *)vc setMode:MyMusicMode_Online];
            }
        }
        
        self.frostedViewController.contentViewController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.frostedViewController hideMenuViewController];
    }
}
@end
