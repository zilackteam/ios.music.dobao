//
//  SearchDetailViewController.h

//
//  Created by thanhvu on 1/17/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "BaseViewController.h"
#include "BaseList.h"

#pragma mark - SearchSectionStyle
typedef NS_OPTIONS(NSInteger, SeachSectionStyle) { // never edit this order, if u wan do that pls edit "home_section_settings.plist" file
    SearchSectionStyleVideo       = 0,
    SearchSectionStyleAlbum       = 1,
    SearchSectionStyleSong        = 2,
};

#pragma mark - SearchSectionSetting
@interface SearchSectionSetting : NSObject<BaseObject>

@property (assign, nonatomic) unsigned int numberOfColumns;
@property (assign, nonatomic) unsigned int numberOfColumnsExtend;
@property (assign, nonatomic, readonly) unsigned int sectionStyle;
@property (strong, nonatomic) NSString *title;

@end


@interface SearchSectionList : BaseList<BaseObject>
- (NSInteger)indexOfSectionStyle:(SeachSectionStyle)style;
@end

@interface SearchDetailViewController : BaseViewController {
    __weak IBOutlet UICollectionView *_collectionView;
}

@property (nonatomic, strong) NSString *keyword;

- (void)fetchDataWithKeyword:(NSString *)keyword;

@end

@interface SearchHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
