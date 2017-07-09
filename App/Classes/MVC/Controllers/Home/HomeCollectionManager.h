//
//  HomeCollectionManager.h
//  music.application
//
//  Created by thanhvu on 3/23/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "BaseList.h"

#define SECTION_INVALID_INDEX   -1

#pragma mark - SectionStyle
typedef NS_OPTIONS(NSInteger, SectionStyle) { // never edit this order, if u wan do that pls edit "home_section_settings.plist" file
    SectionStyleStatus      = 0,
    SectionStyleVideo       = 1,
    SectionStyleAlbum       = 2,
    SectionStyleSong        = 3,
};

#pragma mark - FooterState
typedef NS_OPTIONS(NSInteger, FooterState) {
    FooterState_Loading     = 0,
    FooterState_Narrow      = 1,
    FooterState_Extend      = 2,
};

#pragma mark - SectionSetting
@interface SectionSetting : NSObject<BaseObject>

// init
- (instancetype)initWithState:(FooterState)state numberOfColumns:(int)numberOfColumns title:(NSString *)title;
- (instancetype)initWithState:(FooterState)state numberOfColumns:(int)numberOfColumns extendNumberOfColumns:(int)extendNumberOfColumns title:(NSString *)title;
// properties
@property (assign, nonatomic) FooterState state;
@property (assign, nonatomic) unsigned int numberOfColumns;
@property (assign, nonatomic) unsigned int numberOfColumnsExtend;
@property (assign, nonatomic, readonly) unsigned int sectionStyle;
@property (strong, nonatomic) NSString *title;

@end

#pragma mark - SectionDictionary
@interface SectionItemDictionary : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *itemDict;

- (NSInteger)numberOfItems;
- (void)setValue:(BaseList*)value forStyle: (SectionStyle) style;
- (BaseList *)objectWithStyle:(SectionStyle)style;

@end

#pragma mark - SectionSettingList
@interface SectionSettingList : BaseList<BaseObject>

- (SectionSetting *)sectionByStyle:(SectionStyle) style;
- (void)updateState:(FooterState) state forSectionStyle:(SectionStyle) style;
- (NSInteger)indexOfSectionStyle:(SectionStyle)style;

@end

@interface HomeCollectionManager : NSObject

@end
