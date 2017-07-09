//
//  HomeCollectionManager.m
//  music.application
//
//  Created by thanhvu on 3/23/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeCollectionManager.h"

@implementation SectionSetting

- (instancetype)initWithState:(FooterState)state numberOfColumns:(int)numberOfColumns title:(NSString *)title {
    self = [super init];
    if (self) {
        self.state = state;
        self.numberOfColumns = numberOfColumns;
        self.numberOfColumnsExtend = numberOfColumns;
        self.title = title;
    }
    return self;
}

- (instancetype)initWithState:(FooterState)state numberOfColumns:(int)numberOfColumns extendNumberOfColumns:(int)extendNumberOfColumns title:(NSString *)title {
    self = [[SectionSetting alloc] initWithState:state numberOfColumns:numberOfColumns title:title];
    if (self) {
        self.numberOfColumnsExtend = extendNumberOfColumns;
    }
    
    return self;
}

- (void)setSectionStyle:(unsigned int)sectionStyle {
    _sectionStyle = sectionStyle;
}

+ (id)parseObject:(id)obj {
    SectionSetting *section = [SectionSetting new];
    
    section.title = [obj stringValueKey:@"title"];
    section.numberOfColumns = (int)[obj intValueKey:@"numbercolumn"];
    section.numberOfColumnsExtend = MAX(1, (int)[obj intValueKey:@"numbercolumn_extend"]);
    section.sectionStyle = (SectionStyle)[obj intValueKey:@"sectionstyle"];
    
    return section;
}

@end

@implementation SectionItemDictionary
- (NSInteger)numberOfItems {
    if (!_itemDict) {
        return 0;
    }
    return [[_itemDict allKeys] count];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _itemDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setValue:(BaseList *)value forStyle:(SectionStyle)style {
    if (value != nil) {
        [_itemDict setObject:value forKey:[NSString stringWithFormat:@"%d", (int)style]];
    }
}

- (BaseList *)objectWithStyle:(SectionStyle)style {
    if (!_itemDict || (_itemDict && [[_itemDict allKeys] count] == 0)) {
        return nil;
    } else {
        return [_itemDict objectForKey:[NSString stringWithFormat:@"%d", (int)style]];
    }
}

@end

@implementation SectionSettingList

+ (id)parseObject:(id)obj {
    if (obj && [NSNull null] != obj && [obj isKindOfClass:[NSArray class]]) {
        
        SectionSettingList *sectionList = [SectionSettingList new];
        sectionList.items = [NSMutableArray array];
        
        for (int i = 0; i < [obj count]; i++) {
            id tmp = [obj objectAtIndex:i];
            
            SectionSetting *section = [SectionSetting parseObject:tmp];
            if (section != nil) {
                [sectionList.items addObject:section];
            }
        }
        return sectionList;
    }
    return nil;
}


- (SectionSetting *)sectionByStyle:(SectionStyle) style {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionStyle == %d", style];
    NSArray *filtered = [self.items filteredArrayUsingPredicate:predicate];
    
    if (filtered && [filtered count] > 0) {
        return filtered[0];
    }
    return nil;
}

- (void)updateState:(FooterState) state forSectionStyle:(SectionStyle) style {
    for (SectionSetting *section in self.items) {
        if (section.sectionStyle == style) {
            section.state = state;
        }
    }
}

- (NSInteger)indexOfSectionStyle:(SectionStyle)style {
    for (int i = 0; i < [self.items count]; i++) {
        
        SectionSetting *section = [self itemAtIndex:i];
        if (section.sectionStyle == style) {
            return i;
        }
    }
    return SECTION_INVALID_INDEX;
}

@end

@implementation HomeCollectionManager

@end
